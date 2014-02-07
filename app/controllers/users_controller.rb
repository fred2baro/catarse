# coding: utf-8
class UsersController < ApplicationController
  load_and_authorize_resource except: [:projects]
  inherit_resources
  actions :show, :update, :unsubscribe_notifications, :uservoice_gadget
  respond_to :json, only: [:contributions, :projects]

  def unsubscribe_notifications
    redirect_to user_path(current_user, anchor: 'unsubscribes')
  end

  def uservoice_gadget
    if params[:secret] == ::Configuration[:uservoice_secret_gadget]
      @user = User.find_by_email params[:email]
    end

    render :uservoice_gadget, layout: false
  end

  def show
    show!{
      fb_admins_add(@user.facebook_id) if @user.facebook_id
      @title = "#{@user.display_name}"
      @credits = @user.contributions.can_refund
      @subscribed_to_updates = @user.updates_subscription
      @unsubscribes = @user.project_unsubscribes
    }
  end

  def update
    update! do |success,failure|
      success.html do
        flash[:notice] = t('users.current_user_fields.updated')
      end
      failure.html do
        flash[:error] = @user.errors.full_messages.to_sentence
      end
    end
    return redirect_to user_path(@user, anchor: 'settings')
  end

  def update_password
    @user = User.find(params[:id])
    if @user.update_with_password(params[:user])
      flash[:notice] = t('users.current_user_fields.updated')
    else
      flash[:error] = @user.errors.full_messages.to_sentence
    end
    return redirect_to user_path(@user, anchor: 'settings')
  end
end
