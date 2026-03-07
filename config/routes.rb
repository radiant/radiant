Rails.application.routes.draw do
  # Routes will be rewritten in issue #439.
  # For now, define a minimal root so the app can boot.
  root "site#show_page"
end
