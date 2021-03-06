require 'spec_helper'

module Pageflow
  describe Theming do
    describe '#theme_name' do
      it 'is invalid if not registered' do
        theming = build(:theming, :theme_name => 'unknown')

        theming.valid?

        expect(theming.errors).to include(:theme_name)
      end

      it 'is valid if registered for usage in theming' do
        Pageflow.config.themes.register(:custom)

        theming = build(:theming, theme_name: 'custom')

        expect(theming).to be_valid
      end
    end

    describe '#theme' do
      it 'looks up theme by #theme_name' do
        theming = build(:theming, :theme_name => 'default')

        expect(theming.theme).to be(Pageflow.config.themes.get(:default))
      end
    end

    describe '#cname_domain' do
      it 'removes subdomain' do
        theming = build(:theming, :cname => 'foo.bar.com')

        expect(theming.cname_domain).to eq('bar.com')
      end

      it 'removes multiple subdomain' do
        theming = build(:theming, :cname => 'foo.bar.baz.com')

        expect(theming.cname_domain).to eq('baz.com')
      end

      it 'does not change anything if no subdomain is present' do
        theming = build(:theming, :cname => 'foo.org')

        expect(theming.cname_domain).to eq('foo.org')
      end

      it 'does not change bogus' do
        theming = build(:theming, :cname => 'localhost')

        expect(theming.cname_domain).to eq('localhost')
      end

      it 'is empty if cname is empty' do
        theming = build(:theming, :cname => '')

        expect(theming.cname_domain).to eq('')
      end
    end

    describe '.with_home_url' do
      it 'includes theming with home_url' do
        theming = create(:theming, home_url: 'http://home.example.com')

        expect(Theming.with_home_url).to include(theming)
      end

      it 'does not include theming with blank home_url' do
        theming = create(:theming, home_url: '')

        expect(Theming.with_home_url).not_to include(theming)
      end
    end

    describe '.for_request' do
      it 'uses Pageflow.config.theming_request_scope' do
        Pageflow.config.theming_request_scope = lambda do |themings, request|
          themings.where(cname: request.subdomain)
        end
        matching_theming = create(:theming, cname: 'matching')
        other_theming = create(:theming, cname: 'other')
        request = double('Request', subdomain: 'matching')

        result = Theming.for_request(request)

        expect(result).to eq([matching_theming])
      end
    end
  end
end
