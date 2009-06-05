class Admin::AssetsController < ApplicationController
  helper :assets
  
  make_resourceful do 
    actions :all
    response_for :index do |format|
      format.html { render }
      format.js {
        @template_name = 'index'
        if params[:asset_page] 
          @asset_page = Page.find(params[:asset_page])
          render :partial => 'admin/assets/search_results.html.haml', :layout => false
        else
          render :partial => 'admin/assets/asset_table.html.haml', :locals => { :assets => @assets }, :layout => false
        end
      }
    end
    
    before :index do
      @template_name = 'index'
      if params[:asset_page]
        @page = Page.find(params[:asset_page])
      end
    end
    before :edit do
      @template_name = 'edit'
    end
    before :new do
      @template_name = 'edit'
    end
    
    after :create do
      if params[:page]
        @page = Page.find(params[:page])
        @asset.pages << @page
      end
    end

    after :create_fails do

    end
    
    after :update do
      clear_model_cache
    end
        
    response_for :update do |format|
      format.html { 
        flash[:notice] = "Asset successfully updated."
        redirect_to(params[:continue] ? edit_admin_asset_path(@asset) : admin_assets_path) 
      }
    end
    response_for :create do |format|
      format.html { 
        flash[:notice] = "Asset successfully uploaded."
        redirect_to(@page ? edit_admin_page_path(@page) : (params[:continue] ? edit_admin_asset_path(@asset) : admin_assets_path)) 
      }
      format.js {
        responds_to_parent do
          render :update do |page|
            page.call('Asset.ChooseTabByName', 'page-attachments')
            page.insert_html :bottom, "attachments", :partial => 'assets/asset', :object => @asset, :locals => {:dom_id => "attachment_#{@asset.id}" }    # can i be bothered to find the attachment id?
            page.call('Asset.AddAsset', "attachment_#{@asset.id}")  # we ought to reinitialise the sortable attachments too
            page.visual_effect :highlight, "attachment_#{@asset.id}" 
            page.call('Asset.ResetForm')
          end
        end          
      }
    end
    response_for :create_fails do |format|
      format.html { 
        flash[:error] = "Asset not uploaded."
        render :action => 'new'
      }
      format.js {
        responds_to_parent do
          render :update do |page|
            page.call('Asset.ClearErrors')
            page.insert_html :top, "asset-upload", :partial => 'assets/errors'
            page.call('Asset.ChooseTabByName', 'upload-assets')
            page.visual_effect :highlight, "asset_errors"
            page.call('Asset.ReactivateForm');
          end
        end          
      }
    end
  end
  
  def refresh
    if request.post? 
      unless params[:id]
        @assets = Asset.find(:all)
        @assets.each do |asset|
          asset.asset.reprocess!
          asset.save
        end
        flash[:notice] = "Thumbnails successfully refreshed."
        redirect_to admin_assets_path
      else
        @asset = Asset.find(params[:id])
        @asset.asset.reprocess!
        @asset.save
        flash[:notice] = "Thumbnails successfully refreshed."
        redirect_to edit_admin_asset_path(@asset)
      end
    else
      render "Do not access this url directly"
    end
    
  end
  
  def add_bucket
    @asset = Asset.find(params[:id])
    if (session[:bucket] ||= {}).key?(@asset.asset.url)
      render :nothing => true and return
    end
    asset_type = @asset.image? ? 'image' : 'link'
    session[:bucket][@asset.asset.url] = { :thumbnail => @asset.thumbnail(:thumbnail), :id => @asset.id, :title => @asset.title, :type => asset_type }

    render :update do |page|
      page[:bucket_list].replace_html "#{render :partial => 'bucket'}"
    end
  end
  
  def clear_bucket
    session[:bucket] = nil
    render :update do |page|
      page[:bucket_list].replace_html '<li><p class="note"><em>Your bucket is empty.</em></p></li>'
    end
  end
  
  def attach_asset
    @asset = Asset.find(params[:asset])
    @page = Page.find(params[:page])
    @page.assets << @asset unless @page.assets.include?(@asset)
    clear_model_cache
    render :partial => 'page_assets', :locals => { :page => @page }
    # render :update do |page|
    #   page[:attachments].replace_html "#{render :partial => 'page_assets', :locals => {:page => @page}}"
    # end
    
  end
  
  def remove_asset    
    @asset = Asset.find(params[:asset])
    @page = Page.find(params[:page])
    @page.assets.delete(@asset)
    clear_model_cache
    render :nothing => true
  end
  
  def reorder
    params[:attachments].each_with_index do |id,idx| 
      page_attachment = PageAttachment.find(id)
      page_attachment.position = idx+1
      page_attachment.save
    end
    clear_model_cache
    render :nothing => true
  end
  
  def remove 
    @asset = Asset.find(params[:id])
  end
  
  def destroy
    @asset = Asset.find(params[:id])
    session[:bucket].delete(@asset.asset.url) if session[:bucket] && session[:bucket].key?(@asset.asset.url)
    @asset.destroy
    clear_model_cache
    redirect_to admin_assets_path
  end
  
  protected
  
    def current_objects
      Asset.search(params[:search], params[:filter], params[:page])
    end
    
    def clear_model_cache
      Radiant::Cache.clear if defined?(Radiant::Cache)
    end

end
