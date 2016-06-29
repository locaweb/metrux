module Metrux
  module ConfigBuilders
    class Common
      APP_NAME_KEY = 'METRUX_APP_NAME'.freeze
      ACTIVE_KEY = 'METRUX_ACTIVE'.freeze

      AppNameNotFoundError = Class.new(ConfigurationError)

      def initialize(yaml)
        @yaml = yaml
      end

      def build
        { app_name: app_name, active: active, prefix: prefix }
      end

      private

      attr_reader :yaml

      def app_name
        ENV[APP_NAME_KEY] || yaml[:app_name] || raise(AppNameNotFoundError)
      end

      def active
        return ENV[ACTIVE_KEY] == 'true' if ENV[ACTIVE_KEY].present?

        yaml[:active].presence || false
      end

      def prefix
        without_accent(app_name.underscore)
          .gsub(/\s/, '_') # {\s,_}
          .gsub(/\W/, '') # non-chars
      end

      def without_accent(text)
        # String#parameterize or ActiveSupport::Inflector.transliterate
        # mess with i18n
        #
        # See https://github.com/rails/rails/issues/21939
        text.tr(
          'ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħ' \
          'ÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕ' \
          'ŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž',
          'AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHh' \
          'IIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRr' \
          'RrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz'
        )
      end
    end
  end
end
