![](http://i.imgur.com/JlHfMxf.jpg)

# User Timezone Detector Gem
![Travis build for User Timezone Gem](https://travis-ci.org/jayelkaake/user_timezone.svg?branch=master)

The user timezone detector Gem lets you attach the `detects_timezone` trait to your User, Account or Contact
classes and auto-populate the timezone field with detected attributes.

**Table of Contents**

* [User Timezone Detector Gem](#user-timezone-detector-gem)
  * [Installation](#installation)
  * [Usage](#usage)
    * [Automatically populating the timezone field](#automatically-populating-the-timezone-field)
    * [Getting the current time for a user, contact or account](#getting-the-current-time-for-a-user,-contact-or-account)
    * [Compatible Lookup Combinations](#compatible-lookup-combinations)
    * [What if my local class attributes are different?](#what-if-my-local-class-attributes-are-different?)
  * [Development](#development)
  * [Contributing](#contributing)
  * [Rate Limits](#rate-limits)
  * [License](#license)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'user_timezone'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install user_timezone

## Usage

### Automatically populating the timezone field
This example assumes you have a table called "contacts" and it has a column with "zip" and "country" or some other compatible lookup combinations (see [Compatible Lookup Combinations](#)).
```ruby
class Contact < ActiveRecord::Base
    detects_timezone log: true, on: :before_safe
end
contact = Contact.new(zip: 78729, country: "US")
contact.save!
puts contact.timezone
# OUTPUT: "America/Chicago"
```

### Getting the current time for a user, contact or account
Continuing on from the previous example, we can now also get the current time for the user.
```ruby
contact.current_time
# Output: "2016-02-21T16:37:10.064-06:00"
```
This returns a ruby time object so you can manipulate it whatever way you want.
Here's an example where we check to see if the user is awake:
```ruby
contact_hour = contact.current_time.hour
if (contact_hour > 0 && contact_hour < 8)
    puts "User is still sleeping, don't bother them - it's only #{contact_hour}am their time!"
else
    puts "User is awake, time to party! ┏(-_-)┛ ┗(-_- )┓ ┗(-_-)┛ ┏(-_-)┓ "
end
# OUTPUT (for example if it's 4am for them): User is still sleeping, don't bother them - it's only 4am their time!
```

### Compatible Lookup Combinations
The API will accept any parameters and try to make a best guess of what the timezone is, even if the timezone
guess will be very inaccurate when a broad filter is provided (such as only country). The attributes that will be
looked at are:
 * state - as a province code or full province name. It'll be more accurate with the code for North America.
 * zip  - can be any string
 * country  - as a 2-letter ISO country code
 * city - This can be any string

All fields are case insensitive.

### What if my local class attributes are different?
If your class's attributes are different than "zip", "state", etc you can map them using
 the "using" config in your `detects_timezone` call like this:
```ruby
class Contact < ActiveRecord::Base
    detects_timezone using: { :province => :state, :postal_code => :zip, :country => :country, :city => :city }
end
contact = Contact.new(postal_code: 78729, province: "US")
contact.save!
puts contact.timezone
# OUTPUT: "America/Chicago"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jayelkaake/user_timezone.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## Rate Limits
Since this gem actually hits a free service that links timezones to locations, I've set a rate limit of 60 requests per minute.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

