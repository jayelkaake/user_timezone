require 'spec_helper'
require 'user_timezone/timezone_detector'
describe ::UserTimezone::TimezoneDetector do

  context "with default options" do
    let(:detector) { UserTimezone::TimezoneDetector.new({raise_errors: true }) }
    context "when given a texas/austin state/country/city" do
      let (:user) { double('User', { state: 'TX', country: 'US', city: 'Austin' } ) }
      it 'gives right time zone' do
        expect(detector.detect(user)).to eq('America/Chicago')
      end
    end

    context "when given a Ontario/Toronto country/zip" do
      let (:user) { double('User', { state: 'ON', country: 'CA', zip: 'N1R 7W8' } ) }
      it 'gives right time zone' do
        expect(detector.detect(user)).to eq('America/Toronto')
      end
    end

    context "when given only a zip and country" do
      let (:user) { double('User', { zip: '78729', country: 'US'} ) }
      it 'gives the right time zone still' do
        expect(detector.detect(user)).to eq('America/Chicago')
      end
    end

    context "when given only a country" do
      let (:user) { double('User', { country: 'GB'} ) }
      it 'takes its best guess' do
        expect(detector.detect(user)).to eq('Europe/London')
      end
    end
  end

  context "with aliased options as a hash" do
    let(:detector) { UserTimezone::TimezoneDetector.new({raise_errors: true, using: {
        :province => :state,
        :postal_code => :zip,
    }}) }
    context "when given a texas/austin state/country/city" do
      let (:user) { double('User', { province: 'ON', postal_code: 'N1R 7W9', country: 'CA', city: "Waterloo" } ) }
      it 'gives right time zone' do
        expect(detector.detect(user)).to eq('America/Toronto')
      end
    end
  end

end