# An item for sale in our online store.
#
# Saved in YAML for now, because we can't afford a DB
#
class Product
  include ActiveModel::Model
  include ActiveModel::Attributes

  ##
  # YAML Persistence. Matches ActiveRecord's API as much as possible

  class << self
    require "yaml/store"

    # Default database path.
    DEFAULT_FILE_PATH = Rails.root.join("db", "#{Rails.env}.products.yml")

    # Set the filepath where the YAML data is stored
    # @param [Pathname, String] filepath
    # @return [Pathname]
    def database_filepath=(filepath)
      @database_filepath = Pathname.new(filepath)
    end

    # The filepath where the YAML data is stored
    # @return [Pathname]
    def database_filepath
      @database_filepath || DEFAULT_FILE_PATH
    end

    # All of the products
    # @return [Array<Product>]
    def all
      load_all
    end

    # The maximum value of the given attribute name in the dataset
    # @param [String, Symbol] attribute_name Name of the attribute to return max value for
    # @return [String,Integer,Float]
    def max(attribute_name)
      load_all.select { |record| record.public_send(attribute_name).present? }
              .map(&:"#{attribute_name}")
              .max
    end

    # You tried to fetch a record that doesn't exist
    class Product::RecordNotFound < StandardError
    end

    # @param [Integer, String] id The ID of the product to find
    # @return [Product]
    # @raise [RecordNotFound]
    def find(id)
      where("id" => id.to_i).first || raise(RecordNotFound, "Cannot find product with id=#{id}")
    end

    # @param [Hash] filters The SQL filters to apply to this query.
    # @return [Array<Product>]
    def where(filters = {})
      load_all.filter do |product|
        product.attributes.with_indifferent_access.slice(*filters.keys) ==
          filters.with_indifferent_access
      end
    end

    def count
      all.size
    end

    def save(product, changes = {})
      return false unless product.valid?

      product.attributes = changes

      storage_key = storage_key_for_product(product)
      store_instance(read_only: false) do |store|
        store[storage_key] = safe_storage_attributes(product.attributes)
      end
    end

    def destroy!(product)
      storage_key = storage_key_for_product(product)
      store_instance(read_only: false) do |store|
        store.delete(storage_key)
      end
    end

    protected

    def store_instance(read_only: true, &block)
      ensure_db_exists!

      store = YAML::Store.new(database_filepath.to_s, threadsafe = true)

      store.transaction(read_only) do
        block.call(store)
      end
    end

    # YAML::Store doesn't like it if we try to save data-types not in the permitted
    # class list.
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

    # Ensure we store data in YAML-safe types
    # @param [Hash] attributes
    # @return [Hash]
    def safe_storage_attributes(attributes)
      attributes.transform_values do |value|
        next(value) if SAFE_YAML_TYPES.include?(value.class)

        next(value.to_f) if value.is_a?(Numeric)

        value.to_s
      end
    end

    # The key to save the product under in YAML. Saves as a dictionary, rather
    # than a list, for faster lookup.
    # (e.g. faster to find `product_hash["1-product"]`
    # than `products_array.find { |item| item.id == "1-product"}`.
    # Storage keys are ID first, so that they are faster to sort than if the ID
    # came at the end of the String.
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
          instance.attributes = product_yaml
          instance
        end
      end
    end

    def ensure_db_exists!
      return if File.exist?(database_filepath)

      FileUtils.mkdir_p(File.dirname(database_filepath))
      FileUtils.touch(File.dirname(database_filepath))
    end
  end

  attribute :id, :integer, default: nil

  attribute :sku, :string, default: ""

  attribute :name, :string, default: ""

  attribute :description, :string, default: ""

  attribute :price_amount, :decimal, precision: 10, scale: 2, default: 0.0

  DEFAULT_ISO_CURRENCY = "USD"
  attribute :price_currency, :string, default: DEFAULT_ISO_CURRENCY

  attribute :tax_amount, :decimal, precision: 10, scale: 2, default: 0.0
  attribute :tax_currency, :string, default: DEFAULT_ISO_CURRENCY

  attribute :stock, :integer, default: 0

  validates :name, presence: true

  SKU_PATTERN = /\w{4}\-\w?\d{3}/i
  validates :sku, presence: true, format: SKU_PATTERN

  validates :description, presence: true

  validates :price_amount, presence: true, numericality: { greater_than: 0 }

  ISO_CURRENCY_PATTERN = /[A-Z]{3}/
  validates :price_currency, presence: true, format: ISO_CURRENCY_PATTERN

  validates :price_amount, presence: true, numericality: { greater_than: 0 }

  validates :tax_amount, presence: true, numericality: { greater_than: 0 }

  validates :tax_currency, presence: true, format: ISO_CURRENCY_PATTERN

  validates :stock, presence: true, numericality: { greater_than: 0 }

  def update(new_attributes)
    self.class.save(self, new_attributes.to_hash)
  end

  def save
    self.class.save(self, attributes)
  end


  # You tried to save a record that wasn't valid
  class Product::RecordInvalid < StandardError
  end
  def save!
    save || raise(RecordInvalid)
  end

  def destroy!
    self.class.destroy!(self)
  end

  def persisted?
    id.present?
  end

  def price
    Money.from_amount(price_amount.to_f, price_currency)
  end

  def tax
    Money.from_amount(tax_amount.to_f, tax_currency)
  end

  def as_json(*)
    attributes
  end
end
