# name: discourse-resource-manager
# about: Plugin за управление на ресурси с безплатни файлове
# version: 0.1
# authors: Миленски
# url: https://github.com/your-repo/discourse-resource-manager

enabled_site_setting :resource_manager_enabled

register_asset "stylesheets/resource_manager.scss"

after_initialize do
  module ::ResourceManager
    class Engine < ::Rails::Engine
      engine_name "resource_manager"
      isolate_namespace ResourceManager
    end
  end

  require_dependency "application_controller"

  class ResourceManager::ResourcesController < ::ApplicationController
    requires_plugin "discourse-resource-manager"

    before_action :ensure_logged_in, only: [:create, :update, :destroy]

    def index
      render json: { resources: ResourceManager::Resource.all }
    end

    def show
      resource = ResourceManager::Resource.find(params[:id])
      render json: resource
    end

    def create
      resource = ResourceManager::Resource.new(resource_params)
      if resource.save
        render json: resource, status: :created
      else
        render json: { error: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      resource = ResourceManager::Resource.find(params[:id])
      if resource.update(resource_params)
        render json: resource
      else
        render json: { error: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      resource = ResourceManager::Resource.find(params[:id])
      resource.destroy
      render json: { message: "Resource deleted" }
    end

    private

    def resource_params
      params.require(:resource).permit(:title, :description, :file_url, :category_id)
    end
  end

  ResourceManager::Engine.routes.draw do
    resources :resources
  end

  Discourse::Application.routes.append do
    mount ::ResourceManager::Engine, at: "/resources"
  end
end
