module Recourse
  module Generators
    # Both sides of the association a `references` attribute declares, written into the
    # files the ORM generator has just made and into the parent's own. Private for the
    # reason `Seeds` is.
    module Associations
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
      # what tells it to. `touch:` keeps a cached table honest — `update_counters`
      # bumps the column without touching `updated_at`, so the count would go stale.
      def count_from_belongs_to(attribute)
        gsub_file model_file, /^(\s*belongs_to :#{attribute.name}\b.*)$/,
                  '\1, counter_cache: true, touch: true'
      end

      # And the far side of the association, on the model the key points at — a foreign
      # key read from one side only is half a model. Nothing where that model is not
      # written yet: generate the parent first, or add the line by hand.
      def declare_has_many(attribute)
        parent = File.join 'app/models', "#{attribute.name}.rb"
        return say_status :skip, "#{parent} does not exist" unless exist? parent

        inject_into_class parent, attribute.name.camelize, "  #{far_side}\n"
      end

      # A generated child requires its parent — `belongs_to` says so — so deleting
      # the parent takes its children with it.
      def far_side
        naming = ", class_name: '#{class_name}'" if class_path.any?

        "has_many :#{plural_name}#{naming}, dependent: :destroy"
      end

      def exist?(path)
        File.exist? File.join(destination_root, path)
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
