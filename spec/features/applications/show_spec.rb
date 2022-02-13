require 'rails_helper'

RSpec.describe "Application Show Page" do
  before (:each) do
    @shelter_1 = Shelter.create(name: 'Aurora shelter', city: 'Aurora, CO', foster_program: false, rank: 9)
    @pet_1 = Pet.create(adoptable: true, age: 1, breed: 'sphynx', name: 'Lucille Bald', shelter_id: @shelter_1.id)
    @pet_2 = Pet.create(adoptable: true, age: 3, breed: 'dragon', name: 'Blake C', shelter_id: @shelter_1.id)
    @application = Application.create!(name: "Chaz Carmichael",
      street_address: "10 lane",
      city: "Sandy Springs",
      state: "CO",
      zipcode: 12345,
      description: "I like pets")
    @application2 = Application.create!(name: "Kirby",
      street_address: "15 street",
      city: "Jacob Drive",
      state: "DE",
      zipcode: 64523,
      description: "Cheese is the best")
    @pet_application_test = PetApplication.create!(pet_id: @pet_1.id, application_id: @application.id)
    @pet_application2_test = PetApplication.create!(pet_id: @pet_2.id, application_id: @application.id)
  end

  it "should show applicant information" do

    visit "/application/#{@application.id}"
    expect(page).to have_content(@application.name)
    expect(page).to have_content(@application.street_address)
    expect(page).to have_content(@application.city)
    expect(page).to have_content(@application.zipcode)
    expect(page).to have_content(@application.description)
    expect(page).to have_content(@application.status)
  end

  it "can display links to pet show page" do
    @application.status = 1
    @application.save
    visit "/application/#{@application.id}"
    click_on('Lucille Bald')
    expect(current_path).to eq("/application/pets/#{@pet_1.id}")
    visit "/application/#{@application.id}"
    click_on('Blake C')
    expect(current_path).to eq("/application/pets/#{@pet_2.id}")
  end

  describe "Add a pet section" do
    it 'has a text box to search pets by name' do
      visit "/application/#{@application2.id}"
      expect(page).to have_button("Search")
    end

    it "searches for a pet by name and returns to show page with pets who match search" do
      visit "/application/#{@application2.id}"
      fill_in "Enter Pet Name:", with: "Lucille"
      click_on('Search')
      expect(current_path).to eq("/application/#{@application2.id}")
      expect(page).to have_content(@pet_1.name)
      expect(page).to have_content(@pet_1.breed)
      expect(page).to have_content(@pet_1.age)
      expect(page).to have_content(@shelter_1.name)
      expect(page).to_not have_content(@pet_2.name)
      expect(page).to_not have_content(@pet_2.breed)
    end
  end

  describe "Add a pet to an application" do
    it 'has a button to "Adopt this Pet"' do
      visit "/application/#{@application2.id}"
      fill_in "Enter Pet Name:", with: "l"
      click_on("Search")
      expect(page).to have_link("Adopt this Pet")
      click_on("Adopt this Pet", match: :first)
      expect(current_path).to eq("/application/#{@application2.id}/")
      expect(page).to have_content(@pet_1.name)
    end
  end
end
