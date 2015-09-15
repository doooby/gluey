
class TestMaterial < Minitest::Test

  def test_init_base_attrs
    m = Gluey::Material.new 'cpp', 'glue', :context
    assert_equal :cpp, m.name
    assert_equal 'glue', m.glue
    assert_equal :context, m.instance_variable_get('@context')
    assert_equal [], m.paths
    assert_equal [], m.items
    assert_equal 'cpp', m.asset_extension
    assert_equal 'cpp', m.file_extension
  end

  def test_init_base_attrs2
    m = Gluey::Material.new('css', 'blue', 'much_context'){|_m| _m.set file_extension: 'scss' }
    assert_equal :css, m.name
    assert_equal 'blue', m.glue
    assert_equal 'much_context', m.instance_variable_get('@context')
    assert_equal 'css', m.asset_extension
    assert_equal 'scss', m.file_extension
  end

  def test_init_with_block
    m = Gluey::Material.new('cpp', 'glue', :context) do |_m|
      assert_kind_of Gluey::Material, _m
      _m.set items: [1]
    end
    assert_includes m.items, 1
  end

  def test_set_whitelisted_attrs
    m = Gluey::Material.new 'name', nil, nil
    whitelist = %i(paths items asset_extension file_extension)
    m.set **(whitelist.inject({}){|h, k| h[k] = 1; h})
    whitelist.each do |k|
      assert_equal 1, m.instance_variable_get("@#{k}")
    end
  end

  def test_set_good_and_bad_attrs
    m = Gluey::Material.new 'name', nil, nil
    m.set paths: 1, pavements: 1
    assert_equal 1, m.instance_variable_get('@paths')
    assert !m.instance_variable_defined?('@pavements')
  end

  def test_is_listed_any_file
    m = Gluey::Material.new('js', nil, nil){|_m| _m.set items: [:any]}
    assert m.is_listed?('', '.js')
    assert m.is_listed?('', '.js.erb')
    assert !m.is_listed?('', '.cpp.erb')
  end

  def test_is_listed_by_string
    m = Gluey::Material.new('js', nil, nil){|_m| _m.set items: ['test']}
    assert m.is_listed?('test', '.js')
    assert !m.is_listed?('best', '.js')
  end

  def test_is_listed_by_regexp
    m = Gluey::Material.new('js', nil, nil){|_m| _m.set items: [/[^b]est/]}
    assert m.is_listed?('test', '.js')
    assert !m.is_listed?('best', '.js')
  end

  def test_is_listed_by_proc
    m = Gluey::Material.new('js', nil, nil){|_m| _m.set items: [->(path, file){ path = 'test' && file=='test.js' }]}
    assert m.is_listed?('test', 'test.js')
    assert !m.is_listed?('test', 'best.js')
  end

  def test_find_base_file
    e = Gluey::Environment.new root: TESTS_PATH
    m = Gluey::Material.new('js', nil, e){|_m| _m.set items: [:any], paths: %w(files)}
    assert_equal "#{TESTS_PATH}/files/test.js", m.find_base_file('test')
    assert_equal "#{TESTS_PATH}/files/test2.js.erb", m.find_base_file('test2')
    assert_equal "#{TESTS_PATH}/files/home/index.js", m.find_base_file('home')
    assert_equal "#{TESTS_PATH}/files/work/index.js.erb", m.find_base_file('work')
    assert_raises(Gluey::FileNotFound){ m.find_base_file 'badabum' }
  end

  def test_list_all_items
    e = Gluey::Environment.new root: TESTS_PATH
    m = Gluey::Material.new('js', nil, e){|_m| _m.set items: [:any], paths: %w(files)}
    assert_equal %w(test test2 home home/variable work).sort, m.list_all_items.sort
  end

end