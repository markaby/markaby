module Markaby

  # Common sets of attributes.
  AttrCustom = [:id, :class, :style]
  AttrEvents = [:onclick, :ondblclick, :onmousedown, :onmouseup, :onmouseover, :onmousemove, 
      :onmouseout, :onkeypress, :onkeydown, :onkeyup]
  AttrAnno = [:title, :lang, :dir]
  Attrs = AttrCustom + AttrEvents + AttrAnno

  # Very basic rules from the XHTML 1.0 Strict DTD.
  XHTMLStrictTags = {
    :pre => AttrCustom + AttrAnno + [:space], 
    :em => Attrs,
    :code => Attrs,
    :h2 => Attrs,
    :h3 => Attrs,
    :h1 => Attrs,
    :h6 => Attrs,
    :dl => Attrs,
    :h4 => Attrs,
    :h5 => Attrs,
    :area => Attrs + [:accesskey, :tabindex, :onfocus, :onblur, :shape, :coords, :href, :nohref, :alt], 
    :meta => [:lang, :dir, :id, :name, :content, :scheme, "http-equiv".intern], 
    :table => [], 
    :dfn => Attrs,
    :label => Attrs + [:for, :accesskey, :onfocus, :onblur], 
    :select => Attrs + [:name, :size, :multiple, :disabled, :tabindex, :onfocus, :onblur, :onchange], 
    :noscript => Attrs,
    :style => [:lang, :dir, :id, :type, :media, :title, :space], 
    :strong => Attrs,
    :span => Attrs,
    :sub => Attrs,
    :img => Attrs + [:src, :alt, :longdesc, :height, :width, :usemap, :ismap], 
    :title => [:lang, :dir, :id], 
    :bdo => AttrCustom + [:title] + AttrEvents + [:lang, :dir], 
    :tr => [], 
    :tbody => [], 
    :param => [:id, :name, :value, :valuetype, :type], 
    :li => Attrs,
    :acronym => Attrs,
    :html => [:lang, :dir, :id, :xmlns], 
    :caption => [], 
    :tfoot => [], 
    :th => [], 
    :sup => Attrs,
    :var => Attrs,
    :input => Attrs + [:accesskey, :tabindex, :onfocus, :onblur, :type, :name, :value, :checked, :disabled, :readonly, :size, :maxlength, :src, :alt, :usemap, :onselect, :onchange, :accept], 
    :td => Attrs + [:summary, :width, :border, :frame, :rules, :cellspacing, :cellpadding, :span, :align, :char, :charoff, :valign, :abbr, :axis, :headers, :scope, :rowspan, :colspan], 
    :samp => Attrs,
    :cite => Attrs,
    :thead => [], 
    :body => Attrs + [:onload, :onunload], 
    :map => AttrCustom + [:lang, :dir, ] + AttrEvents + [:title, :name], 
    :head => [:lang, :dir, :id, :profile], 
    :blockquote => Attrs + [:cite], 
    :fieldset => Attrs,
    :option => Attrs + [:selected, :disabled, :label, :value], 
    :form => Attrs + [:action, :method, :enctype, :onsubmit, :onreset, :accept, 'accept-charset'], 
    :hr => Attrs,
    :big => Attrs,
    :dd => Attrs,
    :object => Attrs + [:declare, :classid, :codebase, :data, :type, :codetype, :archive, :standby, :height, :width, :usemap, :name, :tabindex], 
    :base => [:href, :id], 
    :link => Attrs + [:charset, :href, :hreflang, :type, :rel, :rev, :media], 
    :kbd => Attrs,
    :br => AttrCustom + [:title], 
    :address => Attrs,
    :optgroup => Attrs + [:disabled, :label], 
    :dt => Attrs,
    :ins => Attrs + [:cite, :datetime], 
    :b => Attrs,
    :legend => Attrs + [:accesskey], 
    :abbr => Attrs,
    :a => Attrs + [:accesskey, :tabindex, :onfocus, :onblur, :charset, :type, :name, :href, :hreflang, :rel, :rev, :shape, :coords], 
    :ol => Attrs,
    :textarea => Attrs + [:accesskey, :tabindex, :onfocus, :onblur, :name, :rows, :cols, :disabled, :readonly, :onselect, :onchange], 
    :colgroup => [], 
    :i => Attrs,
    :button => Attrs + [:accesskey, :tabindex, :onfocus, :onblur, :name, :value, :type, :disabled], 
    :script => [:id, :charset, :type, :src, :defer, :space], 
    :col => [], 
    :q => Attrs + [:cite], 
    :p => Attrs,
    :del => Attrs + [:cite, :datetime], 
    :small => Attrs,
    :div => Attrs,
    :tt => Attrs,
    :ul => Attrs  
  }

  # Additional tags found in XHTML 1.0 Transitional
  XHTMLTransitionalTags = XHTMLStrictTags.merge \
    :strike => Attrs,
    :center => Attrs,
    :dir => Attrs + [:compact], 
    :noframes => Attrs,
    :basefont => [:id, :size, :color, :face], 
    :u => Attrs,
    :menu => Attrs + [:compact], 
    :iframe => AttrCustom + [:title, :longdesc, :name, :src, :frameborder, :marginwidth, :marginheight, :scrolling, :align, :height, :width], 
    :font => AttrCustom + AttrAnno + [:size, :color, :face], 
    :s => Attrs,
    :applet => AttrCustom + [:title, :codebase, :archive, :code, :object, :alt, :name, :width, :height, :align, :hspace, :vspace], 
    :isindex => AttrCustom + AttrAnno + [:prompt]

  # Additional attributes found in XHTML 1.0 Transitional
  { :script => [:language],
    :a => [:target],
    :td => [:bgcolor, :nowrap, :height],
    :p => [:align],
    :h5 => [:align],
    :h3 => [:align],
    :li => [:type, :value],
    :div => [:align],
    :pre => AttrEvents + [:width],
    :body => [:background, :bgcolor, :text, :link, :vlink, :alink],
    :ol => [:type, :compact, :start],
    :h4 => [:align],
    :h2 => [:align],
    :object => [:align, :border, :hspace, :vspace],
    :img => [:name, :align, :border, :hspace, :vspace],
    :link => [:target],
    :legend => [:align],
    :dl => [:compact],
    :input => [:align],
    :h6 => [:align],
    :hr => [:align, :noshade, :size, :width],
    :base => [:target],
    :ul => [:type, :compact],
    :br => [:clear],
    :form => [:name, :target],
    :area => [:target],
    :h1 => [:align]
  }.each do |k, v|
      XHTMLTransitionalTags[k] += v
  end

  FORM_TAGS = [ :form, :input, :select, :textarea ]
  SELF_CLOSING_TAGS = [ :hr, :br, :link, :meta, :input ]
  NO_PROXY = [ :hr, :br ]

end
