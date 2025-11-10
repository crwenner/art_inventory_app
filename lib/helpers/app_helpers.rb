module AppHelpers
  def format_sold(item)
    item[:sold].to_s == 'true' ? "✅ Sold" : "🖼️ Available"
  end

  def h(text)
    Rack::Utils.escape_html(text.to_s)
  end
end
