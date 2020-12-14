require "#{Rails.root}/lib/tosbackdoc.rb"


# in repo root, run:
# FROM_ID=151 TO_ID=160 USER_ID=789 rails runner db/crawl_documents.rb

$fromId = ENV['FROM_ID']
$toId = ENV['TO_ID']
$userId = ENV['USER_ID']

puts "Crawling documents.."
Document.where(:id => $fromId..$toId).each do |document|
  puts document.id

  puts 'crawling ' + document.url + ' (' + document.xpath + ')'

  @tbdoc = TOSBackDoc.new({
    url: document.url,
    xpath: document.xpath
  })

  @tbdoc.scrape

  oldLength = document.text.length
  puts 'old length ' + oldLength.to_s
  document.update(text: @tbdoc.newdata)
  newLength = document.text.length
  puts 'new length ' + newLength.to_s

  @document_comment = DocumentComment.new()
  @document_comment.summary = 'Crawled, old length: ' + oldLength.to_s + ', new length: ' + newLength.to_s
  @document_comment.user_id = $userId
  @document_comment.document_id = document.id

  if @document_comment.save
    puts "Comment added!"
  else
    puts "Error adding comment!"
    puts @document_comment.errors.full_messages
  end
end
puts "Finished crawling documents!"
