#delete all
Job.delete_all
Startup.delete_all
Location.delete_all
Zillow.delete_all

last_page = AngellistApi.get_jobs(options={ page: 100000 }).last_page

page_num = 1

while page_num <= last_page

  angel_jobs = AngellistApi.get_jobs(options={ page: page_num })

  angel_jobs.jobs.each do |job|

    loc_obj = job.tags.find { |n| n.tag_type == "LocationTag" }
    role_obj = job.tags.find { |n| n.tag_type == "RoleTag" }

    if loc_obj != nil && job.currency_code == 'USD'

      Job.find_by_al_job_id(job.startup.id) ||
          Job.create(al_url: job.angellist_url,
                     al_created_at: job.created_at,
                     currency_code: job.currency_code,
                     role_name: role_obj.display_name,
                     description: job.description,
                     equity_cliff: job.equity_cliff,
                     equity_max: job.equity_max,
                     equity_vest: job.equity_vest,
                     al_job_id: job.id,
                     job_type: job.job_type,
                     remote_ok: job.remote_ok,
                     salary_max: job.salary_max,
                     salary_min: job.salary_min,
                     al_start_id: job.startup.id,
                     al_loc_id: loc_obj.id,
                     title: job.title,
                     al_updated_at: job.updated_at
          )


      Location.find_by_al_loc_id(loc_obj.id) ||
          Location.create(al_url: loc_obj.angellist_url,
                          display_name: loc_obj.display_name,
                          al_loc_id: loc_obj.id,
                          address: loc_obj.name
          )

      sleep 2

      Startup.find_by_al_start_id(job.startup.id) ||
          Startup.create(al_url: job.startup.angellist_url,
                         community_profile: job.startup.community_profile,
                         url: job.startup.company_url,
                         al_created_at: job.startup.created_at,
                         follower_count: job.startup.follower_count,
                         hidden: job.startup.hidden,
                         high_concept: job.startup.high_concept,
                         al_start_id: job.startup.id,
                         logo_url: job.startup.logo_url,
                         name: job.startup.name,
                         prod_desc: job.startup.product_desc,
                         quality: job.startup.quality,
                         thumb_url: job.startup.thumb_url,
                         al_updated_at: job.startup.updated_at,
                         al_loc_id: loc_obj.id
          )

      Zillow.find_by_al_loc_id(loc_obj.id) ||
          if Location.find(loc_obj.id).city != nil && Location.find(loc_obj.id).state != nil

            z_data = Rubillow::Neighborhood.demographics(
                { state: Location.find(loc_obj.id).state,
                  city: Location.find(loc_obj.id).city })


            if z_data.success?
              unless z_data.characteristics['Education'].nil? ||
                  z_data.characteristics['People & Culture'].nil? ||
                  z_data.characteristics['Transportation'].nil?

                Zillow.create(al_loc_id: loc_obj.id,
                              med_house_income: z_data.metrics['People Data']['Median Household Income'][:city].value.to_i,
                              med_nat_house_income: z_data.metrics['People Data']['Median Household Income'][:nation].value.to_i,
                              zillow_HVI: z_data.affordability_data['Zillow Home Value Index'][:city].value.to_i,
                              zillow_nat_HVI: z_data.affordability_data['Zillow Home Value Index'][:nation].value.to_i,
                              avg_commute_time: z_data.metrics['People Data']['Average Commute Time (Minutes)'][:city].value.to_f,
                              avg_nat_commute_time: z_data.metrics['People Data']['Average Commute Time (Minutes)'][:nation].value.to_f,
                              education: z_data.characteristics['Education'].join(', '),
                              people_culture: z_data.characteristics['People & Culture'].join(', '),
                              transportation: z_data.characteristics['Transportation'].join(', ')
                )
              end
            end
          end


      sleep 2

    end

  end

  page_num += 1

end

Location.find_each do |location|

  if location.city != nil && location.state != nil

    z_data = Rubillow::Neighborhood.demographics({ state: location.state, city: location.city })


    if z_data.success?
      unless z_data.characteristics['Education'].nil? || z_data.characteristics['People & Culture'].nil? || z_data.characteristics['Transportation'].nil?
        Zillow.create(al_loc_id: location.al_loc_id,
                      med_house_income: z_data.metrics['People Data']['Median Household Income'][:city].value.to_i,
                      med_nat_house_income: z_data.metrics['People Data']['Median Household Income'][:nation].value.to_i,
                      zillow_HVI: z_data.affordability_data['Zillow Home Value Index'][:city].value.to_i,
                      zillow_nat_HVI: z_data.affordability_data['Zillow Home Value Index'][:nation].value.to_i,
                      avg_commute_time: z_data.metrics['People Data']['Average Commute Time (Minutes)'][:city].value.to_f,
                      avg_nat_commute_time: z_data.metrics['People Data']['Average Commute Time (Minutes)'][:nation].value.to_f,
                      education: z_data.characteristics['Education'].join(', '),
                      people_culture: z_data.characteristics['People & Culture'].join(', '),
                      transportation: z_data.characteristics['Transportation'].join(', ')
        )
      end
    end
  end

  sleep 2

end