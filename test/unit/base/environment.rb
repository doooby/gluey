
class TestEnvironment < Minitest::Test

  def test_init
    block_self = nil
    e = Gluey::Environment.new root: '/', blabla: :why do
      block_self = self
      self.mark_versions = false
    end
    assert_equal e, block_self
    assert_equal '/', e.root
    assert_equal :why, e.instance_variable_get('@blabla')
    assert_equal false, e.mark_versions
  end

  def test_init_no_root
    assert_raises(StandardError){ Gluey::Environment.new }
  end

  def test_asset_url
    Gluey::Environment.class_eval{ define_method(:real_path) {|m, p|'abcdef' } }
    e = Gluey::Environment.new root: '/'
    assert_equal "/assets/js/abcdef", e.asset_url('js', nil)
    e = Gluey::Environment.new root: '/', base_url: 'localhost:3000', path_prefix: '/gass'
    assert_equal "localhost:3000/gass/js/abcdef", e.asset_url('js', nil)
    Gluey::Environment.class_eval{ remove_method :real_path }
  end

end