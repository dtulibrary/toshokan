module Dtu
  # Implements the canonical Presenter pattern
  # @see http://railscasts.com/episodes/287-presenters-from-scratch
  # This has to be a module so Dtu::DocumentPresenter can
  # subclass Blacklight::DocumentPresenter and then include Dtu::PresenterBehavior
  module PresenterBehavior
    extend ActiveSupport::Concern

    def initialize(object, view_context, configuration=view_context.blacklight_config)
      @object = object
      @view_context = view_context
      @configuration = configuration
    end

    included do
      def self.presents(name)
        define_method(name) do
          @object
        end
      end
    end

    private

    def h
      @view_context
    end

    # This forwards undefined methods to
    def method_missing(*args, &block)
      @view_context.send(*args, &block)
    end

  end
end