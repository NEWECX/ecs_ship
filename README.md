# EcsShip

Provides a shipping script for AWS ECS dockerized apps.

## Installation

Add this line to your application's Gemfile, probably in the `development` group:

```ruby
gem 'ecs_ship'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ecs_ship
    
Create a script (probably in `bin/deploy`) similar to the following:

        #!/usr/bin/env ruby
        
        gem 'ecs_ship'
        require 'ecs_ship/deploy'
        
        args = [ARGV[0], 'example_aws_ecs_service_name', 'example_aws_ecs_task_name', 'example_docker_image_name', ARGV[1]].compact
        EcsShip::Deploy.new(*args).deploy

## Usage examples

* `./bin/deploy help`
* `./bin/deploy my_cluster_name_for_this_app` (keeps same docker tag as current)
* `./bin/deploy my_cluster_name_for_this_app` `latest`
* `./bin/deploy my_cluster_name_for_this_app` `new_docker_tag`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ecs_ship.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

