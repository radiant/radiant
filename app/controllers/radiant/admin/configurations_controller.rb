module Radiant
  class Admin::ConfigurationsController < ::Radiant::AdminController

    # Admin::ConfigurationController handles the batch-updating of Radiant::Config entries.
    # It accepts any set of config name-value pairs but is accessible only to administrators.
    # Note that configuration is routed as a singular resource so we only deal with show/edit/update
    # and the show and edit views determine what set of config values is shown and made editable.

    before_filter :initialize_detail

    only_allow_access_to :edit, :update,
      when: [:admin],
      denied_url: { controller: 'admin/configuration', action: 'show' },
      denied_message: 'You must have admin privileges to edit site configuration.'

    def show
      @user = current_user
      render
    end

    def edit
      render
    end

    def update
      if params[:config]
        begin
          Radiant.detail.transaction do
            params["config"].each_pair do |key, value|
              @editable_detail[key] = Radiant::Config.find_or_create_by(key: key)
              @editable_detail[key].value = value      # validation sets errors on @editable_config['key'] that the helper methods will pick up
            end
            redirect_to action: :show
          end
        rescue ActiveRecord::RecordInvalid => e
          flash[:error] = "Configuration error: please check the form"
          render action: :edit
        rescue Radiant::Config::ConfigError => e
          flash[:error] = "Configuration error: #{e}"
          render action: :edit
        end
      end
    end

  protected

    def initialize_detail
      @editable_detail = {}
    end

  end
end