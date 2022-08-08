# frozen_string_literal: true

module AhoyAdmin
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
