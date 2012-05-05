module Markaby
  FORM_TAGS         = [ :form, :input, :select, :textarea ]
  SELF_CLOSING_TAGS = [:area, :base, :br, :col, :command, :embed, :frame, :hr,
                       :img, :input, :keygen, :link, :meta, :param, :source,
                       :track, :wbr]

  # Common sets of attributes.
  AttrCore   = [:id, :class, :style, :title]
  AttrI18n   = [:lang, 'xml:lang'.intern, :dir]
  AttrEvents = [:onclick,
                :ondblclick,
                :onmousedown,
                :onmouseup,
                :onmouseover,
                :onmousemove,
                :onmouseout,
                :onkeypress,
                :onkeydown,
                :onkeyup]
  AttrFocus  = [:accesskey, :tabindex, :onfocus, :onblur]
  AttrHAlign = [:align, :char, :charoff]
  AttrVAlign = [:valign]
  Attrs      = AttrCore + AttrI18n + AttrEvents
  
  AttrsBoolean = [
    :checked, :disabled, :multiple, :readonly, :selected, # standard forms
    :autofocus, :required, :novalidate, :formnovalidate, # HTML5 forms
    :defer, :ismap, # <script defer>, <img ismap>
    :compact, :declare, :noresize, :noshade, :nowrap # deprecated or unused
  ]

  # All the tags and attributes from XHTML 1.0 Strict
  class XHTMLStrict
    class << self
      attr_accessor :tags, :tagset, :forms, :self_closing, :doctype
    end

    @doctype = ['-//W3C//DTD XHTML 1.0 Strict//EN', 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd']
    @tagset  = {
      :html       => AttrI18n + [:id, :xmlns],
      :head       => AttrI18n + [:id, :profile],
      :title      => AttrI18n + [:id],
      :base       => [:href, :id],
      :meta       => AttrI18n + [:id, :http, :name, :content, :scheme, 'http-equiv'.intern],
      :link       => Attrs    + [:charset, :href, :hreflang, :type, :rel, :rev, :media],
      :style      => AttrI18n + [:id, :type, :media, :title, 'xml:space'.intern],
      :script     => [:id, :charset, :type, :src, :defer, 'xml:space'.intern],
      :noscript   => Attrs,
      :body       => Attrs + [:onload, :onunload],
      :div        => Attrs,
      :p          => Attrs,
      :ul         => Attrs,
      :ol         => Attrs,
      :li         => Attrs,
      :dl         => Attrs,
      :dt         => Attrs,
      :dd         => Attrs,
      :address    => Attrs,
      :hr         => Attrs,
      :pre        => Attrs + ['xml:space'.intern],
      :blockquote => Attrs + [:cite],
      :ins        => Attrs + [:cite, :datetime],
      :del        => Attrs + [:cite, :datetime],
      :a          => Attrs + AttrFocus + [:charset, :type, :name, :href, :hreflang, :rel, :rev, :shape, :coords],
      :span       => Attrs,
      :bdo        => AttrCore + AttrEvents + [:lang, 'xml:lang'.intern, :dir],
      :br         => AttrCore,
      :em         => Attrs,
      :strong     => Attrs,
      :dfn        => Attrs,
      :code       => Attrs,
      :samp       => Attrs,
      :kbd        => Attrs,
      :var        => Attrs,
      :cite       => Attrs,
      :abbr       => Attrs,
      :acronym    => Attrs,
      :q          => Attrs + [:cite],
      :sub        => Attrs,
      :sup        => Attrs,
      :tt         => Attrs,
      :i          => Attrs,
      :b          => Attrs,
      :big        => Attrs,
      :small      => Attrs,
      :object     => Attrs + [:declare, :classid, :codebase, :data, :type, :codetype, :archive, :standby, :height, :width, :usemap, :name, :tabindex],
      :param      => [:id, :name, :value, :valuetype, :type],
      :img        => Attrs + [:src, :alt, :longdesc, :height, :width, :usemap, :ismap],
      :map        => AttrI18n + AttrEvents + [:id, :class, :style, :title, :name],
      :area       => Attrs + AttrFocus + [:shape, :coords, :href, :nohref, :alt],
      :form       => Attrs + [:action, :method, :enctype, :onsubmit, :onreset, :accept, :accept],
      :label      => Attrs + [:for, :accesskey, :onfocus, :onblur],
      :input      => Attrs + AttrFocus + [:type, :name, :value, :checked, :disabled, :readonly, :size, :maxlength, :src, :alt, :usemap, :onselect, :onchange, :accept],
      :select     => Attrs + [:name, :size, :multiple, :disabled, :tabindex, :onfocus, :onblur, :onchange],
      :optgroup   => Attrs + [:disabled, :label],
      :option     => Attrs + [:selected, :disabled, :label, :value],
      :textarea   => Attrs + AttrFocus + [:name, :rows, :cols, :disabled, :readonly, :onselect, :onchange],
      :fieldset   => Attrs,
      :legend     => Attrs + [:accesskey],
      :button     => Attrs + AttrFocus + [:name, :value, :type, :disabled],
      :table      => Attrs + [:summary, :width, :border, :frame, :rules, :cellspacing, :cellpadding],
      :caption    => Attrs,
      :colgroup   => Attrs + AttrHAlign + AttrVAlign + [:span, :width],
      :col        => Attrs + AttrHAlign + AttrVAlign + [:span, :width],
      :thead      => Attrs + AttrHAlign + AttrVAlign,
      :tfoot      => Attrs + AttrHAlign + AttrVAlign,
      :tbody      => Attrs + AttrHAlign + AttrVAlign,
      :tr         => Attrs + AttrHAlign + AttrVAlign,
      :th         => Attrs + AttrHAlign + AttrVAlign + [:abbr, :axis, :headers, :scope, :rowspan, :colspan],
      :td         => Attrs + AttrHAlign + AttrVAlign + [:abbr, :axis, :headers, :scope, :rowspan, :colspan],
      :h1         => Attrs,
      :h2         => Attrs,
      :h3         => Attrs,
      :h4         => Attrs,
      :h5         => Attrs,
      :h6         => Attrs
    }

    @tags         = @tagset.keys
    @forms        = @tags & FORM_TAGS
    @self_closing = @tags & SELF_CLOSING_TAGS
  end

  # Additional tags found in XHTML 1.0 Transitional
  class XHTMLTransitional
    class << self
      attr_accessor :tags, :tagset, :forms, :self_closing, :doctype
    end

    @doctype = ['-//W3C//DTD XHTML 1.0 Transitional//EN', 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd']
    @tagset = XHTMLStrict.tagset.merge({
      :strike   => Attrs,
      :center   => Attrs,
      :dir      => Attrs + [:compact],
      :noframes => Attrs,
      :basefont => [:id, :size, :color, :face],
      :u        => Attrs,
      :menu     => Attrs + [:compact],
      :iframe   => AttrCore + [:longdesc, :name, :src, :frameborder, :marginwidth, :marginheight, :scrolling, :align, :height, :width],
      :font     => AttrCore + AttrI18n + [:size, :color, :face],
      :s        => Attrs,
      :applet   => AttrCore + [:codebase, :archive, :code, :object, :alt, :name, :width, :height, :align, :hspace, :vspace],
      :isindex  => AttrCore + AttrI18n + [:prompt]
    })

    # Additional attributes found in XHTML 1.0 Transitional
    additional_tags = {
      :script => [:language],
      :a      => [:target],
      :td     => [:bgcolor, :nowrap, :width, :height],
      :p      => [:align],
      :h5     => [:align],
      :h3     => [:align],
      :li     => [:type, :value],
      :div    => [:align],
      :pre    => [:width],
      :body   => [:background, :bgcolor, :text, :link, :vlink, :alink],
      :ol     => [:type, :compact, :start],
      :h4     => [:align],
      :h2     => [:align],
      :object => [:align, :border, :hspace, :vspace],
      :img    => [:name, :align, :border, :hspace, :vspace],
      :link   => [:target],
      :legend => [:align],
      :dl     => [:compact],
      :input  => [:align],
      :h6     => [:align],
      :hr     => [:align, :noshade, :size, :width],
      :base   => [:target],
      :ul     => [:type, :compact],
      :br     => [:clear],
      :form   => [:name, :target],
      :area   => [:target],
      :h1     => [:align]
    }

    additional_tags.each do |k, v|
      @tagset[k] += v
    end

    @tags = @tagset.keys
    @forms = @tags & FORM_TAGS
    @self_closing = @tags & SELF_CLOSING_TAGS
  end

  # Additional tags found in XHTML 1.0 Frameset
  class XHTMLFrameset
    class << self
      attr_accessor :tags, :tagset, :forms, :self_closing, :doctype
    end

    @doctype = ['-//W3C//DTD XHTML 1.0 Frameset//EN', 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd']
    @tagset = XHTMLTransitional.tagset.merge({
      :frameset => AttrCore + [:rows, :cols, :onload, :onunload],
      :frame    => AttrCore + [:longdesc, :name, :src, :frameborder, :marginwidth, :marginheight, :noresize, :scrolling]
    })

    @tags = @tagset.keys
    @forms = @tags & FORM_TAGS
    @self_closing = @tags & SELF_CLOSING_TAGS
  end

  class HTML5
    class << self
      attr_accessor :tags, :tagset, :forms, :self_closing, :doctype
    end

    @doctype = ['html']
    @tagset = XHTMLTransitional.tagset.merge({
        :abbr => Attrs,
        :article => Attrs,
        :aside => Attrs,
        :audio => Attrs,
        :bdi => Attrs,
        :canvas => Attrs,
        :command => Attrs,
        :datalist => Attrs,
        :details => Attrs,
        :embed => Attrs,
        :figure => Attrs,
        :figcaption => Attrs,
        :footer => Attrs,
        :header => Attrs,
        :hgroup => Attrs,
        :keygen => Attrs,
        :mark => Attrs,
        :menu => Attrs,
        :meter => Attrs,
        :nav => Attrs,
        :output => Attrs,
        :progress => Attrs,
        :rp => Attrs,
        :rt => Attrs,
        :ruby => Attrs,
        :section => Attrs,
        :source => Attrs,
        :time => Attrs,
        :track => Attrs,
        :video => Attrs,
        :wbr => Attrs
    })

    # Additional attributes found in HTML5
    additional_tags = {
      :a => [:media, :download, :ping],
      :area => [:media, :download, :ping, :hreflang, :rel, :type],
      :base => [:target],
      :button => [:autofocus, :form, :formaction, :formenctype, :formmethod,
                  :formnovalidate, :formtarget],
      :fieldset => [:form, :disabled, :name],
      :form => [:novalidate],
      :label => [:form],
      :html => [:manifest],
      :iframe => [:sandbox, :seamless, :srcdoc],
      :img => [:crossorigin],
      :input => [:autofocus, :placeholder, :form, :required, :autocomplete,
                 :min, :max, :multiple, :pattern, :step, :list, :width, :height,
                 :dirname, :formaction, :formenctype, :formmethod,
                 :formnovalidate, :formtarget],
      :link => [:sizes],
      :meta => [:charset],
      :menu => [:type, :label],
      :object => [:form],
      :ol => [:reversed],
      :object => [:typemustmatch],
      :output => [:form],
      :script => [:async],
      :select => [:autofocus, :form, :required],
      :style => [:scoped],
      :textarea => [:autofocus, :placeholder, :form, :required, :dirname,
                    :maxlength, :wrap],
    }

    AttrsHTML5  = [:contenteditable, :contextmentu, :draggable, :dropzone,
                   :hidden, :role, :spellcheck, :translate]

    additional_tags.each do |k, v|
      @tagset[k] += v
    end

    @tagset.each do |k, v|
      @tagset[k] += AttrsHTML5
    end

    @tags = @tagset.keys
    @forms = @tags & FORM_TAGS
    @self_closing = @tags & SELF_CLOSING_TAGS
  end
end
