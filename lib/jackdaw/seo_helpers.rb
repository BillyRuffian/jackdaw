# frozen_string_literal: true

module Jackdaw
  # SEO meta tag helpers for templates
  module SEOHelpers
    # Generate Open Graph meta tags
    def og_tags(title:, description:, url:, type: 'website', image: nil)
      tags = []
      tags << %(<meta property="og:title" content="#{escape_html(title)}" />)
      tags << %(<meta property="og:description" content="#{escape_html(description)}" />)
      tags << %(<meta property="og:url" content="#{escape_html(url)}" />)
      tags << %(<meta property="og:type" content="#{escape_html(type)}" />)
      tags << %(<meta property="og:image" content="#{escape_html(image)}" />) if image

      tags.join("\n    ")
    end

    # Generate Twitter Card meta tags
    def twitter_tags(title:, description:, card: 'summary', image: nil, site: nil, creator: nil)
      tags = []
      tags << %(<meta name="twitter:card" content="#{escape_html(card)}" />)
      tags << %(<meta name="twitter:title" content="#{escape_html(title)}" />)
      tags << %(<meta name="twitter:description" content="#{escape_html(description)}" />)
      tags << %(<meta name="twitter:image" content="#{escape_html(image)}" />) if image
      tags << %(<meta name="twitter:site" content="#{escape_html(site)}" />) if site
      tags << %(<meta name="twitter:creator" content="#{escape_html(creator)}" />) if creator

      tags.join("\n    ")
    end

    # Generate canonical link tag
    def canonical_tag(url)
      %(<link rel="canonical" href="#{escape_html(url)}" />)
    end

    # Generate meta description tag
    def meta_description(description)
      %(<meta name="description" content="#{escape_html(description)}" />)
    end

    # Generate all basic SEO tags at once
    def seo_tags(title:, description:, url:, image: nil, type: 'website')
      tags = []
      tags << meta_description(description)
      tags << canonical_tag(url)
      tags << og_tags(title: title, description: description, url: url, type: type, image: image)
      tags << twitter_tags(title: title, description: description, image: image)

      tags.join("\n    ")
    end

    private

    def escape_html(text)
      return '' unless text

      text.to_s
          .gsub('&', '&amp;')
          .gsub('<', '&lt;')
          .gsub('>', '&gt;')
          .gsub('"', '&quot;')
          .gsub("'", '&#39;')
    end
  end
end
