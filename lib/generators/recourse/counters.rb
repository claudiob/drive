module Recourse
  module Generators
    # The counter cache a `references` attribute earns, written into the two files the
    # ORM generator has just made. Private for the reason `Seeds` is.
    module Counters
      # What the parent's column is worth adding to the migration for: a polymorphic
      # reference names no one table, so there is nowhere to put the count.
      def counted_attributes
        attributes.select { |one| one.reference? && !one.polymorphic? }
      end

    private

      # After `create_table`, which is the first line indented that far, and before the
      # indexes the template writes under it.
      def add_counter_column(attribute)
        return unless migration_file

        column = "    add_column :#{attribute.name.pluralize}, :#{table_name}_count, " \
                 ":integer, default: 0, null: false\n"

        inject_into_file migration_file, column, after: "    end\n"
      end

      # The other half of the same decision: the column is Rails' to keep, and this is
      # what tells it to.
      def count_from_belongs_to(attribute)
        gsub_file model_file, /^(\s*belongs_to :#{attribute.name}\b.*)$/, '\1, counter_cache: true'
      end

      def model_file
        File.join 'app/models', class_path, "#{file_name}.rb"
      end

      # Named by the ORM generator with a timestamp this one never saw, so it is found
      # rather than known. Nothing is there to find under `--pretend`.
      def migration_file
        pattern = File.join destination_root, 'db/migrate', "*_create_#{table_name}.rb"

        Dir.glob(pattern).max
      end
    end
  end
end
