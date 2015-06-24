require 'spec_helper'

feature 'Starting a new game' do
  scenario 'I am asked to enter my name' do
    visit '/'
    click_link 'Start 1 player game'
    expect(page).to have_content "What is your name you seafaring scoundrel?"
  end

  scenario 'I can enter my name' do
    visit '/new_game'
    fill_in('name', with: 'Michael')
    click_on 'Submit'
    expect(page).to have_content 'You are now registered, Michael!'

  end

  scenario 'I can click a link to start the game' do
    visit '/new_game'
    fill_in('name', with: 'Michael')
    click_on 'Submit'
    click_link 'Begin your adventure'
    expect(page).to have_content 'Enter the coordinate you want to hit!'
  end

end
