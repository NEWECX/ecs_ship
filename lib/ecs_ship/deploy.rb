require 'json'

module EcsShip
  class Deploy
    def initialize(cluster_name, service_name, task_name, docker_image_name, docker_tag = 'latest')
      @cluster_name = cluster_name
      @docker_tag = docker_tag
      @service_name = service_name
      @task_name = task_name
      @docker_image_name = docker_image_name

      raise "Invalid cluster name, valid clusters are: #{cluster_names}" unless cluster_names.any?{|available_name| available_name == cluster_name}
    end

    def deploy
      stop_existing_task
      rev_task_version
      start_updated_task

      puts "Shipped! #{@service_name} should now be running #{versioned_task_name}"

    rescue StandardError => e
      syntax
      raise e
    end

    def stop_existing_task
      puts 'Stopping existing task... yes this is a downtime deployment'

      running_task_arns = JSON.parse(`aws ecs list-tasks --cluster #{@cluster_name} --family #{@task_name} --desired-status RUNNING`)['taskArns']
      running_task_arns.each do |task_arn|
        system("aws ecs stop-task --cluster #{@cluster_name} --task #{task_arn}")
      end

      success = system("aws ecs update-service --cluster #{@cluster_name} --service #{@service_name} --desired-count 0")
      unless success
        raise 'Failed to stop existing task'
      end
    end

    def rev_task_version
      begin
        puts 'Creating new task definition with updated version number'

        task_definition = JSON.parse(`aws ecs describe-task-definition --task-definition #{@task_name}`)['taskDefinition']

        @revision = task_definition['revision'] + 1

        registerable_params = [:family, :taskRoleArn, :networkMode, :containerDefinitions, :volumes, :placementConstraints]

        task_definition['containerDefinitions'].map! do |container_definition|
          if container_definition['image'].include?(@docker_image_name)
            container_definition['image'] = "#{@docker_image_name}:#{@docker_tag}"
          end
          container_definition
        end

        File.open(temp_definition_path, 'w') do |file|
          file.write(task_definition.select{|k, v| registerable_params.include?(k.to_sym)}.to_json)
        end

        success = system("aws ecs register-task-definition --family #{@task_name} --cli-input-json file://#{temp_definition_path}")
        unless success
          raise 'Failed to rev task version'
        end
      ensure
        File.delete(temp_definition_path)
      end
    end

    def temp_definition_path
      'temp_definition_delete_me.json'
    end

    def start_updated_task
      puts 'Starting service back up with newly created task definition'

      success = system("aws ecs update-service --cluster #{@cluster_name} --service #{@service_name} --desired-count 1 --task-definition #{versioned_task_name}")
      unless success
        raise 'Failed to start back up the updated service'
      end
    end

    def versioned_task_name
      "#{@task_name}:#{@revision}"
    end

    def all_clusters
      @all_clusters ||= JSON.parse(`aws ecs describe-clusters --clusters #{cluster_arns.join(' ')}`)['clusters']
    end

    def cluster_arns
      JSON.parse(`aws ecs list-clusters`)['clusterArns']
    end

    def cluster_names
      all_clusters.map{|c| c['clusterName']}
    end

    def syntax
      puts "Arguments: #{method(:initialize).parameters.map{|p| "#{p.last} (#{p.first})"}.join(' ')}"
      puts "\n"
      puts "Valid stacks: #{cluster_names}}"
    end
  end
end
