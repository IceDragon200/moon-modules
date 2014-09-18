##
# Based loosely off the RPG Maker RPG::BaseItem class
module Moon
  module DataModel
    class Base < Metal
      field :id,   type: String,           default: proc {Random.random.base64(16)} # ID
      field :name, type: String,           default: proc {""} # Name of this model
      field :note, type: String,           default: proc {""} # A string for describing this DataModel
      array :tags, type: String                               # Used for lookups
      field :meta, type: {String=>String}, default: proc {{}} # Meta Data, String Values and String Keys
    end
  end
end
