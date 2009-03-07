require 'active_record'

class ActiveRecord::Base
  def self.object_id_attr(symbol, klass)
    module_eval %{
      def #{symbol}
        if @#{symbol}.nil? or (@old_#{symbol}_id != #{symbol}_id)
          @old_#{symbol}_id = #{symbol}_id
          klass = #{klass}.descendants.find { |d| d.#{symbol}_name == #{symbol}_id }
          klass ||= #{klass}
          @#{symbol} = klass.new
        else
          @#{symbol}
        end
      end
    }
  end
end

# Rails 2.1 uses a raw 'db/migrate' Dir-glob, resulting in failure to
# assume a proper migration version in instance mode.
warn "Re-check assume_migrated_upto_version compatibility. (#{__FILE__}: #{__LINE__})" if Rails.version !~ /^2\.1/ 
module ActiveRecord::ConnectionAdapters::SchemaStatements
  def assume_migrated_upto_version(version)
    version = version.to_i
    sm_table = quote_table_name(ActiveRecord::Migrator.schema_migrations_table_name)

    migrated = select_values("SELECT version FROM #{sm_table}").map(&:to_i)
    versions = Dir["#{RADIANT_ROOT}/db/migrate/[0-9]*_*.rb"].map do |filename|
      filename.split('/').last.split('_').first.to_i
    end

    unless migrated.include?(version)
      execute "INSERT INTO #{sm_table} (version) VALUES ('#{version}')"
    end

    inserted = Set.new
    (versions - migrated).each do |v|
      if inserted.include?(v)
        raise "Duplicate migration #{v}. Please renumber your migrations to resolve the conflict."
      elsif v < version
        execute "INSERT INTO #{sm_table} (version) VALUES ('#{v}')"
        inserted << v
      end
    end
  end
end
