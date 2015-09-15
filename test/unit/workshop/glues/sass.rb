class TestSassGlue < Minitest::Test

  def test_process_w_engine_opts
    glue.engine_opts = {line_comments: false}
    g = glue.new Gluey::Workshop.new(TESTS_PATH),
                 Gluey::Material.new('scss', nil, nil)
    dependencies = []
    result = g.process File.join(TESTS_PATH, 'files', 'base.scss'), dependencies
    expected = <<RDOC
div {
  background-color: black; }
RDOC
    assert_equal expected, result
  end

  private

  def glue
    @glue ||= Gluey::Glues.load('sass')
  end

end