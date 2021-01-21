require 'test/unit'
require 'mk4rb'

module MetakitTestHelper
  def R filename
    # assert that we delete it actually
    File.delete filename rescue nil
  end
  
  def W filename
    File.delete filename rescue nil
  end
end

class MetakitBaseTest < Test::Unit::TestCase
  include MetakitTestHelper
  
  # to make test unit happy
  def test_dummy
    assert true
  end
end
