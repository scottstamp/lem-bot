require 'sequel'

DB = Sequel.sqlite('reminders.db')

DB.create_table? :queue do
	primary_key :id
	String	:channel
	String	:nick
	String	:message
	Int		:entered_at
	Int		:remind_at
end

class Item < Sequel::Model(:queue)
end

class LemDB
	def add_remind(channel=:channel, nick=:nick, message=:message, remind_at=:remind_at)
		Item.create(
			:channel => channel,
			:nick => nick,
			:message => message,
			:entered_at => Time.now.to_i,
			:remind_at => remind_at
		)
	end

	def fetch(ts=:ts, delay=:delay)
		# Add or Subtract 2 to the delay, to appropriately handle network lag.
		match_start	= ts - delay - 2
		match_end	= ts + delay + 2
		Item.where{remind_at > match_start}.where{remind_at < match_end}
	end
end
