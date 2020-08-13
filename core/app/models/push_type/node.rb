module PushType
  class Node < ActiveRecord::Base

    include PushType::Customizable
    include PushType::Nestable
    include PushType::Templatable
    include PushType::Unexposable
    include PushType::Publishable
    include PushType::Trashable
    include PushType::Presentable

    belongs_to :creator, class_name: 'PushType::User', optional: true
    belongs_to :updater, class_name: 'PushType::User', optional: true

    has_closure_tree name_column: 'slug', order: 'sort_order', dependent: :destroy

    validates :title, presence: true
    validates :slug,  presence: true, uniqueness: { scope: :parent_id }

    after_save :after_save
    before_destroy :before_destroy

    def self.find_by_base64_id(secret)
      find Base64.urlsafe_decode64(secret)
    rescue ArgumentError
      raise ActiveRecord::RecordNotFound
    end

    def base64_id
      Base64.urlsafe_encode64 id.to_s
    end

    def permalink
      @permalink ||= self_and_ancestors.map(&:slug).reverse.join('/')
    end

    def orphan?
      parent && parent.trashed?
    end

    def trash!
      super
      self.descendants.update_all deleted_at: Time.zone.now
    end

    protected

    def after_save
      cb = PushType::Config.after_save
      cb.call(self) if cb.is_a?(Proc)
    end

    def before_destroy
      cb = PushType::Config.before_destroy
      cb.call(self) if cb.is_a?(Proc)
    end
  end
end
