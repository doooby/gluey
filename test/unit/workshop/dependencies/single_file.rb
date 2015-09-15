Gluey::Glues.load 'script'

class TestDepSingleFile < Minitest::Test

  def test_initialization
    d = Gluey::Dependencies::SingleFile.new variable_file, something: :nothing, whatever: 42
    assert_equal variable_file, d.file
    assert_equal({something: :nothing, whatever: 42}, d.data)
  end

  def test_actualize
    d = Gluey::Dependencies::SingleFile.new(variable_file).actualize
    assert_kind_of Gluey::Dependencies::SingleFile, d
    assert_equal File.mtime(variable_file).to_i, d.instance_variable_get('@mtime')
  end

  def test_changed?
    d = Gluey::Dependencies::SingleFile.new(variable_file).actualize
    File.write variable_file, "blargh#{rand}"
    sleep 0.001
    assert d.changed?
  end

  def test_exists?
    d = Gluey::Dependencies::SingleFile.new variable_file
    assert d.exists?
  end

  def test_equal
    d1 = Gluey::Dependencies::SingleFile.new variable_file
    d2 = Gluey::Dependencies::SingleFile.new variable_file
    d3 = Gluey::Dependencies::SingleFile.new File.join(TESTS_PATH, 'files', 'home', 'index.js')
    assert d1==d2
    assert d1!=d3
  end

  def test_mark
    d = Gluey::Dependencies::SingleFile.new variable_file
    assert_equal File.mtime(variable_file).to_i.to_s, d.mark
  end

  private

  def variable_file
    @variable_file ||= File.join(TESTS_PATH, 'files', 'home', 'variable.js')
  end

end