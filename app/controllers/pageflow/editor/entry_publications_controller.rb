module Pageflow
  module Editor
    class EntryPublicationsController < Pageflow::ApplicationController
      respond_to :json

      before_filter :authenticate_user!

      def create
        entry = Entry.find(params[:entry_id])

        authorize!(:publish, entry)
        verify_edit_lock!(entry)

        @entry_publication = build_entry_publication(entry)
        @entry_publication.save!

        render(action: :check)
      rescue Quota::ExceededError
        render(action: :check, status: :forbidden)
      end

      def check
        entry = Entry.find(params[:entry_id])

        authorize!(:publish, entry)

        @entry_publication = build_entry_publication(entry)
      end

      private

      def build_entry_publication(entry)
        EntryPublication.new(entry,
                             entry_publication_params,
                             published_entries_quota,
                             current_user)
      end

      def entry_publication_params
        params.fetch(:entry_publication, {}).permit(:published_until)
      end

      def published_entries_quota
        Pageflow.config.quotas.get(:published_entries, current_user.account)
      end
    end
  end
end
