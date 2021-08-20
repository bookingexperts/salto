# Salto

A ruby Salto client implementing the PMS Industry Standard protocol via TCP/IP.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'salto'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install salto

## Usage

```ruby
# Initialize client
client = Salto::Client.new('192.168.1.1:8090', logger: Logger.new(STDOUT))

# Send ENQ
client.ready?

# Encode card
message = Salto::Messages::EncodeCard.new(valid_from: Time.now, valid_till: 2.days.from_now, rooms: ['Room 1'], print_info: 'john', encoder: 'Online Encoder 1')
response = client.send_message(message)
response.message?
response.message

# Encode mobile
message = Salto::Messages::EncodeMobile.new(valid_from: Time.now, valid_till: 2.days.from_now, rooms: ['Room 1'], phone_number: '0612345678', text_message: 'Please enter')
response = client.send_message(message)

# Encode mobile binary
message = Salto::Messages::EncodeMobileBinary.new(valid_from: Time.now, valid_till: 2.days.from_now, rooms: ['Room 1'], phone_number: '0612345678', return_installation_id: true)
response = client.send_message(message)
binary_mobile_key = Salto::Support::BinaryMobileKey.new(response.message)
binary_mobile_key.key

# Read card
lt_message = Salto::Messages::ReadCard.new(encoder: 'Online Encoder 1')
response = client.send_message(lt_message)
card_details = Salto::Support::CardDetails.new(response.message)
card_details.guest_card?

# Write track
p1_message = Salto::Messages::WriteTrack.new(track: 1, encoder: 'Online Encoder 1', text: 'JOHN DOE')
response = client.send_message(p1_message)

# Read track
l1_message = Salto::Messages::ReadTrack.new(track: 1, encoder: 'Online Encoder 1')
response = client.send_message(l1_message)
track1_text = response.message.fields[2]

# Checkout
co_message = Salto::Messages::Checkout.new(room: 'Room 1')
response = client.send_message(co_message)

# Audit trail
audit_trail = Salto::Audit::AuditTrail.fetch(client, door_identification: 'Entrance')
audit_trail.map(&:datetime)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bookingexperts/salto.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
