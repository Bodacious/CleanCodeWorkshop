class Product
  # You forgot to create the database storage YAML file
  class DatabaseNotDefined < StandardError;end

  ##
  # YAML Persistence. Matches ActiveRecord's API as much as possible

  class << self
    require "yaml/store"
    require "bigdecimal"

    # Register BigDecimal as a safe class for YAML deserialization
    DEFAULT_FILE_PATH = Rails.root.join("db", "products.yml")

    def database_filepath=(filepath)
      @database_filepath = filepath
    end

    def database_filepath
      @database_filepath || DEFAULT_FILE_PATH
    end

    def all
      load_all
    end

    def max(attribute_name)
      load_all.select { |record| record.public_send(attribute_name).present? }
              .max { |a, b| a.public_send(attribute_name) <=> b.public_send(attribute_name) }
              .try(attribute_name)
    end

    def find(id)
      where("id" => id).first
    end

    def where(filters = {})
      load_all.filter do |product|
        product.attributes.with_indifferent_access.slice(*filters.keys) == filters.with_indifferent_access
      end
    end

    def save(product)
      storage_key = storage_key_for_product(product)
      store_instance(read_only: false) do |store|
        store[storage_key] = safe_storage_attributes(product.attributes)
      end
    end

    protected


    def store_instance(read_only: true, &block)
      ensure_db_exists!

      store = YAML::Store.new(database_filepath, true, symbolize_names: true)

      store.transaction(read_only) do
        block.call(store)
      end
    end

    SAFE_YAML_TYPES = [
      TrueClass,
      FalseClass,
      NilClass,
      Integer,
      Float,
      String,
      Array,
      Hash
    ].freeze
    private_constant :SAFE_YAML_TYPES

    def safe_storage_attributes(attributes)
      attributes.transform_values do |value|
        next(value) if SAFE_YAML_TYPES.include?(value.class)

        next(value.to_f) if value.is_a?(Numeric)
        value.to_s
      end
    end

    def storage_key_for_product(product)
      product.id = generate_new_id_for_product! unless product.persisted?
      "#{product.id}-product"
    end

    def generate_new_id_for_product!
      max(:id).to_i + 1
    end

    def load_all
      ensure_db_exists!
      store_instance(read_only: true) do |store|
        store.keys.sort.map do |key|
          product_yaml = store[key]
          instance = new
          instance.set_attributes(product_yaml)
          instance
        end
      end
    end

    def ensure_db_exists!
      raise DatabaseNotDefined, "Please ensure #{database_filepath} exists" unless File.exist?(database_filepath)
    end
  end

  ##
  # Attributes

  include ActiveModel::Attributes

  attribute :id, :integer, default: nil

  attribute :sku, :string, default: ""

  attribute :name, :string, default: ""

  attribute :description, :string, default: ""

  attribute :price_amount, :decimal, precision: 10, scale: 2, default: 0.0
  attribute :price_currency, :string, default: "USD"

  attribute :tax_amount, :decimal, precision: 10, scale: 2, default: 0.0
  attribute :tax_currency, :string, default: "USD"

  attribute :stock, :integer, default: 0

  ##
  # Persistence instance methods

  def initialize(attributes = {})
    super()
    set_attributes(attributes)
  end

  def set_attributes(new_attributes = {})
    new_attributes.each_pair do |key, value|
      public_send("#{key}=", value)
    end
  end

  def save
    self.class.save(self)
    true
  end

  def persisted?
    id.present?
  end

  ##
  # Attributes

  def price
    Money.from_amount(price_amount.to_f, price_currency)
  end

  def tax
    Money.from_amount(tax_amount.to_f, tax_currency)
  end
end
