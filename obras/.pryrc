# (C) 2019 Crafted by Roberto Nogueira
# email : roberto.nogueira@tecnogrupo.com.br.com
# trello: robertonogueira17

Pry.config.pager = true
Pry.config.color = true
# Pry.config.history.should_save = true

# wrap ANSI codes so Readline knows where the prompt ends
def colour(name, text)
  if Pry.color
    "\001#{Pry::Helpers::Text.send name, '{text}'}\002".sub '{text}', "\002#{text}\001"
  else
    text
  end
end

Pry.config.prompt = [
    proc do |object, nest_level, pry|
      prompt  = colour :bright_black, Pry.view_clip(object)
      prompt += ":#{nest_level}" if nest_level > 0
      if defined?(Rails::Console)
        prompt += colour :green, " #{_db}"
      end
      prompt += colour :cyan, " > "
    end, proc { |object, nest_level, pry| colour :cyan, "> " }
]

# tell Readline when the window resizes
old_winch = trap 'WINCH' do
  if `stty size` =~ /\A(\d+) (\d+)\n\z/
    Readline.set_screen_size $1.to_i, $2.to_i
  end
  old_winch.call unless old_winch.nil? || old_winch == 'SYSTEM_DEFAULT'
end

# use awesome print for output if available
begin
  require 'amazing_print'
  AmazingPrint.pry!
rescue LoadError => err
  Pry.config.print = Pry::DEFAULT_PRINT
end

# used to print the content tables when typed, e.g. accesses, status_types..etc
if defined?(Rails::Console)
  def self.method_missing(m, *args, &block)
    class_name = "#{m}".classify.constantize
    if class_name.is_a?(Class) && ActiveRecord::Base.connection.table_exists?("#{m}")
      case class_name.to_s
      when 'ServiceGrid'
        if args[0].present?
          service_id = args[0]

          grid_ids = ServiceGrid.where(service_id: service_id).pluck(:grid_id)
          puts
          tp Grid.where(id: grid_ids), :id, :name
        else
          puts
          puts "usage: service_grids <service_id>".magenta
          puts
        end
      else
        if (class_name.respond_to? 'name') && (class_name.all.count < 100)
          puts
          tp class_name.all, :id, :name
        else
          puts
          tp class_name.all.limit(20), class_name.column_names[0..8]
        end
      end
    end
  end
end

class String
  def black;          "\e[30m#{self}\e[0m" end
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def brown;          "\e[33m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def magenta;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def gray;           "\e[37m#{self}\e[0m" end

  def bg_black;       "\e[40m#{self}\e[0m" end
  def bg_red;         "\e[41m#{self}\e[0m" end
  def bg_green;       "\e[42m#{self}\e[0m" end
  def bg_brown;       "\e[43m#{self}\e[0m" end
  def bg_blue;        "\e[44m#{self}\e[0m" end
  def bg_magenta;     "\e[45m#{self}\e[0m" end
  def bg_cyan;        "\e[46m#{self}\e[0m" end
  def bg_gray;        "\e[47m#{self}\e[0m" end

  def bold;           "\e[1m#{self}\e[22m" end
  def italic;         "\e[3m#{self}\e[23m" end
  def underline;      "\e[4m#{self}\e[24m" end
  def blink;          "\e[5m#{self}\e[25m" end
  def reverse_color;  "\e[7m#{self}\e[27m" end
end

class Object
  private
  def populate(name, &block)
    self.class.send(:define_method, name) do

      instance_variable_name = '@_' + name
      value = instance_variable_get(instance_variable_name)

      unless value
        value = block.call
        instance_variable_set(instance_variable_name, value)
      end

      value
    end
  end
end

# handle ActiveRecord database and logs
module Databases
  def _log
    Logger::INFO
  end

  def _log_off
    @old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
  end

  def _log_on
    ActiveRecord::Base.logger = @old_logger
  end

  def _db
    ActiveRecord::Base.connection.current_database
  end

  def _db_config
    ActiveRecord::Base.connection_config
  end
end

# handy methods for obras
module Obras

  if defined?(Rails::Console)

    class Project < Project
      def survey
        project = {}
        project[:project] = {id: self.id}
        project[:status_type] = Hash[*self.status_type.deep_pluck(:id, :name).values]
        project[:service] = Hash[*self.service.deep_pluck(:id, :name).values]
        project[:agency] = Hash[*self.agency.deep_pluck(:id, :name).values]
        project[:grids] = self.grids.pluck(:position, :name).to_h
        if self.proprietary.present? && self.proprietaries.present?
          project[:proprietaries] = {proprietary: Hash[self.proprietary.id, self.proprietary.full_name], others: self.proprietaries.others(self).select {|p| Hash[p.id, p.full_name]}}
        end
        project[:reports] = self.reports.joins(:access).pluck(:id, :name).to_h
        project
        # JSON.parse(project.to_json, object_class: OpenStruct);
      end

      def pluck_to_hash(fields)
        Hash[*fields]
      end

      def grids
        service_grid_ids = self.service.service_grids.pluck(:grid_id)
        ModuleAdderGrid.joins(:grid).where(grid_id: service_grid_ids)
      end

      def include_grid?(name = 'Identificação da Solicitação')
        self.grids.include? name
      end

      def request_reasons
        service_id = self.service.id
        request_reason_ids = MotiveAndServiceAssociation.where(service_id: service_id).pluck(:request_reason_id)
        RequestReason.where(id: request_reason_ids, active: true).pluck(:name)
      end
    end

  end
end


if defined?(Rails::Console)
  include Databases
  include Obras

  populate('cookie_erika') do "aVRBNXlDLyswUE5GSkZ4cjRTa2xDZHp5bGtEVEVvV1g3czFGc1Q1UGNiSDRrWDY1eExaVWh3ZlBaT3ZCbG1iQjBrUytIcHp5SVREV2REakwzOStpdG50YXlrK1I0ZUNuSDJrTmZEbmM0MkxyT1NXa1ZCNXlSMHFDSFN2YlZuaisrdEZrNjdGUS9ha3h1a3R5R0tCdU9Yd0NzajZzdi9BdFRVVkZxWC9kOG1Ud2ZTZVg3UkZvcE00ck1IdHh6MW5NT2tncTlDaVFFV1Q1VmpvZXZucUhUTkRMbEZGWkdNMjVRb3Fmc0hSc0Rlb3JrS1FkbnlaaUhjNy8zVUJyd1NrQzBwY0dDQ0hsb05pK1U3bkdnOXFNRDJOTFA3SG1NT1JiRlF0UHFMRjJITlJaVlgzVk5FUWxRamNselRrMEJ5RVlYUS9rVERoT0J6OXFKY285d2c5TXRyclozc3FXb2o2ZGEwTEhBZnA4ZkU1TUFmcmovU2hDdWN6S211Q2pyc1cyVnl0R3lNUWVlWlExRnJubXlrWGJwS21HcldaSGM0enl4ekowWDJBZDZDdFNBZ250SVNXR0wrM01UbjAvTGFrU1ZKYUhadjY0NGUrdktXQ2tmaC9MbENleUV2WGY2T0hBa2ZRMkZiVjVlanl6YlFZeW15NWVKSUlkL0x0ZWs5ZlYtLXRCT1dQT2psdjNVd1JOajMzQTFqK1E9PQ%3D%3D--1679c5fe6f08b61404fff3562b74e549ddbe6862"
  end

  populate('cookie_suporte') do "TTdJQnY3RlU2TUhuMzNCUkphK2R4SmNoa25ld2F0c1BMakF6a29SM3JYenJiRkdySXJhREJ0MlcybjBLb1FqMUZzcUQxTVk0QzFrajJUbmdTZ0ZVSHBtUVJOZlV6TkcyY1RjaFVDalhBQVhaNmRJM0hFcEVjVkgwaWEyeU5uYU9EL1RrVzh4WVluNHdqTERHa2lBMUJPV1hrSzdUZG9CNm1CZ3NWZzI5UkY0ZnFDWENhVUY3cUdWL3pWOE5Eclk5VC92Z1FTdlJka3EwWHRaZStzakxOeFZHb2NkUlZ4MzQ3MkJ2QnppMWd4WEhWV3VjeC80RVlTNTE3UW9HblliandsQWwycER3ZUZGVkN1SnA3UmJUMkFZMG11RC9kTTFqRFBmSE04K3RvcTNmYkNibzBMYWJQWnlHRm9YWEVwc2F3NkZPUWtucWh2Ylg5YnM4VnI2T05rd28xaFBLcEpJalByUVNwdTIyUTRDWmhyMjkwek5pemlleW5mdnVFVm9rWGpzTEtZRVpyYThmUmhxdFEzVTVCSlFMd2xtSlR4OVJzZjBFNUdsUG02ZTQ5NmtsdW9GVW1VVzk0dmV6Q0RBWGtlN0NDZlFaazVna2tGOXYxYWpaeEF1UEQ0OWFhRHp3YjUySkpOZ1lBM0lGOFJVMkM2QWduZy9hVVplSFN5VVgtLTRsTGp5UjZDaTlvbmJvaFFyaW1mNWc9PQ%3D%3D--73b26ac691c068d2cce06e3a698af65946558bb2"
  end

  def encrypt(cookie)
    if ENV['RAILS_ENV'] != 'development'
      secret_key_base = "ca82ec34944e8a2a25ab3350a5e96680ab65ad80fc2a91722c032143365a8df93cc460f0ca8c98ee4ce33ed831d5f2025a7b4ac18978d10ced72c56d001fb68d"
    elsif  ENV['RAILS_ENV'] == 'test'
      secret_key_base = "fafb750d35c8ad6e4886f6873fcf3f470cbd060a86a2dee546a8ea74bcd8576ee4cd09f42697da8b79d2f3b65834d1ef568e9a319695e855ef040aa8e24e46d7"
    end  
    secret = ActiveSupport::KeyGenerator.new(secret_key_base, iterations: 1000).generate_key("encrypted cookie")
    sign_secret = ActiveSupport::KeyGenerator.new(secret_key_base, iterations: 1000).generate_key("signed encrypted cookie")
    encryptor = JSON.parse(ActiveSupport::MessageEncryptor.new(secret, sign_secret, serializer: ActiveSupport::MessageEncryptor::NullSerializer).decrypt_and_verify(URI.unescape(cookie)))

    access_id = encryptor["access"]["access_id"]
    agency_id = encryptor["agency"]["agency_id"]
    profile_id = encryptor["profile"]["profile_id"]
    user_id = encryptor["warden.user.user.key"][0][0]

    undef access if respond_to? :access
    undef agency if respond_to? :agency
    undef profile if respond_to? :profile
    undef user if respond_to? :user
    undef projects if respond_to? :projects
    undef project if respond_to? :project

    populate('access') do
      Access.find(access_id)
    end
    populate('agency') do
      Agency.find(agency_id)
    end
    populate('profile') do
      Profile.find(profile_id)
    end
    populate('user') do
      User.find(user_id)
    end
    populate('projects') do
      Project.default_access(access, user, profile, agency, opts={status: 1})
    end
    populate('project') do
      projects.first
    end
  end
  
  # encrypt(cookie_suporte) if ['test', 'development'].include? ENV['RAILS_ENV']

  _log_on
end
