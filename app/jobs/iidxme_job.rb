# frozen_string_literal: true

class IidxmeJob < ApplicationJob
  queue_as :iidxme

  def perform(id)
    user = User.find(id)
    puts %(#{Time.zone.now} #{user.djname}[#{user.iidxid}] => iidxme sync start)
    Scrape::IIDXME.new.sync(user.iidxid)
    puts %(#{Time.zone.now} #{user.djname}[#{user.iidxid}] => iidxme sync done)
  end
end