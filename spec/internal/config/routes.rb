# frozen_string_literal: true

Rails.application.routes.draw do
  mount AhoyAdmin::Engine, at: "/ahoy"
end
