=begin
    Copyright 2013 Tasos Laskos <tasos.laskos@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
=end

class ProfilesController < ApplicationController
    before_filter :authenticate_user!
    before_filter :prepare_plugin_params

    load_and_authorize_resource

    # GET /profiles
    # GET /profiles.json
    def index
        @profiles = Profile.all

        respond_to do |format|
            format.html # index.html.erb
            format.json { render json: @profiles }
        end
    end

    # GET /profiles/1
    # GET /profiles/1.json
    def show
        @profile = Profile.find( params.require( :id ) )

        respond_to do |format|
            format.html # show.html.erb
            format.js { render @profile }
            format.json { render json: @profile }
        end
    end

    # GET /profiles/new
    # GET /profiles/new.json
    def new
        @profile = Profile.new

        respond_to do |format|
            format.html # new.html.erb
            format.json { render json: @profile }
        end
    end

    # GET /profiles/1/copy
    def copy
        @profile = Profile.find( params.require( :id ) ).dup

        respond_to do |format|
            format.html { render 'new' }
        end
    end


    # GET /profiles/1/edit
    def edit
        @profile = Profile.find( params.require( :id ) )
    end

    # PUT /profiles/1/make_default
    def make_default
        Profile.find( params.require( :id ) ).make_default

        @profiles = Profile.all

        render partial: 'table', formats: :js
    end

    # POST /profiles
    # POST /profiles.json
    def create
        @profile = Profile.new( strong_params )

        respond_to do |format|
            if @profile.save
                format.html { redirect_to @profile, notice: 'Profile was successfully created.' }
                format.json { render json: @profile, status: :created, location: @profile }
            else
                format.html { render action: "new" }
                format.json { render json: @profile.errors, status: :unprocessable_entity }
            end
        end
    end

    # PUT /profiles/1
    # PUT /profiles/1.json
    def update
        @profile = Profile.find( params.require( :id ) )

        respond_to do |format|
            if @profile.update_attributes( strong_params )
                format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @profile.errors, status: :unprocessable_entity }
            end
        end
    end

    # DELETE /profiles/1
    # DELETE /profiles/1.json
    def destroy
        @profile = Profile.find( params.require( :id ) )
        fail 'Cannot delete default profile.' if @profile.default?

        @profile.destroy

        respond_to do |format|
            format.html { redirect_to profiles_url }
            format.json { head :no_content }
        end
    end

    private

    def strong_params
        params.require( :profile ).
            permit( :name, :audit_cookies, :audit_cookies_extensively, :audit_forms,
                    :audit_headers, :audit_links, :authed_by, :auto_redundant,
                    :cookies, :custom_headers, :depth_limit, :exclude,
                    :exclude_binaries, :exclude_cookies, :exclude_vectors,
                    :extend_paths, :follow_subdomains, :fuzz_methods, :http_req_limit,
                    :include, :link_count_limit, :login_check_pattern, :login_check_url,
                    :max_slaves, :min_pages_per_instance, :modules, :plugins, :proxy_host,
                    :proxy_password, :proxy_port, :proxy_type, :proxy_username,
                    :redirect_limit, :redundant, :restrict_paths, :user_agent,
                    :http_timeout, :description )
    end

    def prepare_plugin_params
        return if !params[:profile]

        if params[:profile][:selected_plugins]
            selected_plugins = {}
            (params[:profile][:selected_plugins] || []).each do |plugin|
                selected_plugins[plugin] = params[:profile][:plugins][plugin]
            end

            params[:profile][:plugins] = selected_plugins
            params[:profile].delete( :selected_plugins )
        else
            params[:profile][:plugins] = {}
        end
    end

end
