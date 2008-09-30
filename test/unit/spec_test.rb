require File.dirname(__FILE__) + '/../test_helper'

class SpecTest < ActiveSupport::TestCase
  
  def setup
    @valid_spec = specs(:valid_spec)
  end
  
  def test_max_length
    Spec::STRING_FIELDS.each do |field|
      assert_length :max, @valid_spec, field, DB_STRING_MAX_LENGTH
    end
  end
  
  def test_blank
    blank = Spec.new(:user_id => @valid_spec.id)
    assert blank.save, blank.errors.full_messages.join("\n")
  end
  
  def test_invalid_birthdates
    spec = @valid_spec
    invalid_birthdates = [Date.new(Spec::START_YEAR-1), Date.today + 1.year]
    invalid_birthdates.each do |date|
      spec.birthdate = date
      assert !spec.valid?
      assert spec.errors.invalid?(:birthdate)
    end
  end
  
  def test_zip_code_with_valid_examples
    spec = @valid_spec
    valid_zip_codes = %w(91124 55434 37898 80725 65213)
    valid_zip_codes.each do |zip_code|
      spec.zip_code = zip_code
      assert spec.valid?, "#{zip_code} should pass validation but doesn't"
    end
  end
  
  def test_zip_code_with_invalid_examples
    spec = @valid_spec
    invalid_zip_codes = %w(OU812 5325 314159)
    invalid_zip_codes.each do |zip_code|
      spec.zip_code = zip_code
      assert !spec.valid?, "#{zip_code} shouldn't pass validation but does"
      assert spec.errors.invalid?(:zip_code)
    end
  end
  
  def test_gender_with_valid_examples
    spec = @valid_spec
    Spec::VALID_GENDERS.each do |valid_gender|
      spec.gender = valid_gender
      assert spec.valid?, "#{valid_gender} should pass validation but doesnt"
    end
  end
  
  def test_gender_with_invalid_examples
    spec = @valid_spec
    invalid_genders = ["Eunuch", "Hermaphrodite", "Third Gender"]
    invalid_genders.each do |invalid_gender|
      spec.gender = invalid_gender
      assert !spec.valid?, "#{invalid_gender} shouldn't pass validation but does"
      assert spec.errors.invalid?(:gender)
    end
  end
  
end
