module Recourse
  module Generators
    # What a `references` attribute earns at generation time: the counter column
    # written into the migration just made, and the names `Associations` needs for
    # the model files around it. Private for the reason `Seeds` is.
    module References
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

        # Named from `plural_name`, never `table_name`: `counter_cache: true` on an
        # Admin::Job maintains `jobs_count`, and `admin_jobs_count` would sit dead.
        column = "    add_column :#{attribute.name.pluralize}, :#{plural_name}_count, " \
                 ":integer, default: 0, null: false\n"

        inject_into_file migration_file, column, after: "    end\n"
      end

      # A generated child requires its parent — `belongs_to` says so — so deleting
      # the parent takes its children with it.
      def far_side
        naming = ", class_name: '#{class_name}'" if class_path.any?

        "has_many :#{plural_name}#{naming}, dependent: :destroy"
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
