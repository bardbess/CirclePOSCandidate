Rails.application.routes.draw do
  namespace :api do
    get "monthly-comparison", to: "monthly_comparisons#show"
  end
end
