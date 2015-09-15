class TestGlue < Minitest::Test

  def test_read_base_file
    Gluey::Environment.class_eval{ define_method(:get_binding){ binding } }
    g = Gluey::Glues::Base.new Gluey::Environment.new(root: 'blargh'), nil
    res = g.read_base_file File.join(TESTS_PATH, 'files', 'test2.js.erb')
    assert_equal "var blargh = 'blargh';", res
    Gluey::Environment.class_eval{ remove_method(:get_binding) }
  end

  def test_load
    assert_raises(NameError){Gluey::Glues::JsScript}
    res = Gluey::Glues.load 'js_script', 'uglifier'
    assert_equal Gluey::Glues::JsScript, res
    assert_respond_to Gluey::Glues::JsScript, :uglifier
  end

end