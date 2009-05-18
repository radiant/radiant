When /^I send an ["'](.*)["'] header of ['"](.*)['"]$/ do |key, value|
  @request_headers ||= {}
  @request_headers[key] = value
end

When /^I go to ['"](.*)['"]$/ do |url|
  set_headers
  visit url
end

When /^I request the children of page ['"](\w+)['"]$/ do |page|
  parent_page = pages(page.intern)
  set_headers
  visit "/admin/pages/#{parent_page.id}/children", :get, {"level" => "0"}
end

def set_headers
  @request_headers.each do |k,v|
    header(k, v)
  end unless @request_headers.blank?
end