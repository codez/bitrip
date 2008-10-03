class Rip < ActiveRecord::Base
  
  has_many :navi_actions, :order => 'position', :dependent => :destroy
  has_many :bits, :order => 'position', :dependent => :destroy
  
  validates_uniqueness_of :name
  validates_format_of :start_page, :with => /^https?:\/\/.+/
  
 
  def bit_order
    (0..(bits.size - 1)).to_a
  end
  
  def requires_input?
    navi_actions.any? { |navi| navi.requires_input? }
  end
  
  def build_from(params)
    self.attributes = params[:rip]
    
    # build navi actions
    self.navi_actions.clear
    params[:navi].values.each_with_index do |navi, index|
      navi_action = self.navi_actions.build navi
      navi_action.type = navi[:type] unless navi[:type].empty?
      
      # build form fields
      fields = params[:fields][index.to_s]
      if fields
        fields.each_value do |field|
          form_field = navi_action.form_fields.build field
          puts field[:value]
          form_field.type = field[:type]
        end
      end
    end
    
    # build bitss
    self.bits.clear
    pos = 1
    params[:bit_order].split(',').each do |index|
      bit_attrs = params[:bits][index]
      if bit_attrs
        bit_attrs[:position] = pos
        self.bits.build(bit_attrs)
        pos += 1
      end  
    end
  end
end
