require 'rails_helper'

describe AssistanceRequestsController do
  before do
    @user = login FactoryGirl.create(:dtu_employee)
    @ability = FactoryGirl.build :ability
    allow(controller).to receive(:current_ability).and_return @ability
  end

  describe '#index' do
    before do
      other_user = FactoryGirl.create :dtu_employee, :identifier => '4321', :email => 'other@dtu.dk'
      @request1 = FactoryGirl.create :journal_article_assistance_request, :user => @user
      @request2 = FactoryGirl.create :conference_article_assistance_request, :user => other_user
    end

    context 'when user can request assistance' do
      before do
        @ability.can :request, :assistance
      end

      context 'when user can view all requests' do
        before do
          @ability.can :view, :all_assistance_requests
        end

        it 'assigns all requests' do
          get :index
          expect( assigns[:assistance_requests]  ).to eq [@request1, @request2]
        end

        it 'renders the "index" template' do
          get :index
          expect(response).to render_template :index
        end
      end

      context 'when user can view own requests' do
        before do
          @ability.can :view, :own_assistance_requests
        end

        it 'assigns all requests for the current user' do
          get :index
          expect( assigns[:assistance_requests]  ).to eq @request1
        end

        it 'renders the "index" template' do
          get :index
          expect(response).to render_template :index
        end
      end

      context 'when user cannot view requests' do
        it 'returns an HTTP 404' do
          get :index
          expect( response.response_code ).to eq 404
        end
      end

    end

    context 'when user cannot request assistance' do
      it 'returns an HTTP 404' do
        get :index
        expect( response.response_code ).to eq 404
      end
    end
  end



  describe '#new' do
    context 'when user can request assistance' do
      before do
        @ability.can :request, :assistance
      end

      context 'with record_id parameter' do
        it 'checks if there is a record with the given id' do
          allow(subject).to receive(:get_solr_response_for_doc_id).with('123').and_raise(Blacklight::Exceptions::InvalidSolrID)
          get :new, :record_id => '123'
        end

        context 'when record exists' do
          {
            'journal_article' => '123',
          }.each do |genre, record_id|
            context "when record is a #{genre}" do
              it 'returns an HTTP 404' do
                allow(subject).to receive(:get_solr_response_for_doc_id).with(record_id).and_return([{}, FactoryGirl.build(genre)])
                get :new, :record_id => record_id
                expect(response.response_code).to eq 404
              end
            end
          end

          {
            'conference_article' => '123',
            'thesis'             => '234',
            'report'             => '345',
            'standard'           => '456',
            'patent'             => '567',
            'book'               => '678'
          }.each do |genre, record_id|
            context "when record is a #{genre}" do
              before do
                allow(subject).to receive(:get_solr_response_for_doc_id).with(record_id).and_return([{}, FactoryGirl.build(genre)])
              end

              it 'assigns the genre' do
                get :new, :record_id => record_id
                expect(assigns[:genre]).to eq genre.to_sym
              end

              it 'assigns the assistance request' do
                get :new, :record_id => record_id
                expect(assigns[:assistance_request]).to be_a Module.const_get("#{genre}_assistance_request".classify)
              end

              it 'renders the "new" template' do
                get :new, :record_id => record_id
                expect(subject).to render_template :new
              end
            end
          end

          context 'when record is something else' do
            before do
              allow(subject).to receive(:get_solr_response_for_doc_id).with('123').and_return([{}, FactoryGirl.build(:other)])
            end

            it 'assigns other genre' do
              get :new, :record_id => '123'
              expect(assigns[:genre]).to eq :other
            end

            it 'assigns other assistance request' do
              get :new, :record_id => '123'
              expect(assigns[:assistance_request]).to be_a OtherAssistanceRequest
            end

            it 'renders the "new" template' do
              get :new, :record_id => '123'
              expect(subject).to render_template :new
            end
          end
        end

        context 'when record does not exist' do
          it 'returns an HTTP 404' do
            allow(subject).to receive(:get_solr_response_for_doc_id)
                              .with('123').and_raise(Blacklight::Exceptions::InvalidSolrID)
            get :new, :record_id => '123'
            expect(response.response_code).to eq 404
          end
        end
      end

      context 'with valid genre parameter' do
        ['journal article', 'conference article', 'book', 'thesis', 'report', 'standard', 'patent', 'other'].each do |genre|
          context "when genre is #{genre}" do
            it "assigns a new #{genre} assistance request object" do
              get :new, :genre => genre.gsub(' ', '_').to_sym
              expect( assigns[:assistance_request].class.name.underscore ).to eq "#{genre.gsub ' ', '_'}_assistance_request"
            end

            it 'renders the "new" template' do
              get :new, :genre => genre.gsub(' ', '_').to_sym
              expect(response).to render_template :new
            end
          end
        end
      end
    end

    context 'when user cannot request assistance' do
      it 'renders the "need_to_login" template' do
        get :new
        expect(response).to render_template :cant_request_assistance
      end
    end
  end



  describe '#create' do
    context 'when user can request assistance' do
      before do
        @ability.can :request, :assistance
      end

      context 'with valid parameters' do
        context 'when button parameter is confirm' do
          ['journal article', 'conference article', 'book', 'thesis', 'report', 'standard', 'other'].each do |genre|
            context "when genre is #{genre}" do
              it 'stores the assistance request' do
                expect {
                  post :create, FactoryGirl.build(form_posts[genre], :button => 'confirm')
                }.to change(assistance_request_classes[genre], :count).by 1
              end

              it 'creates an order for the request' do
                expect {
                  post :create, FactoryGirl.build(form_posts[genre], :button => 'confirm')
                }.to change(Order, :count).by 1
              end

              it 'creates an issue in library support redmine' do
                allow(LibrarySupport).to receive(:delay).and_return LibrarySupport
                expect(LibrarySupport).to receive :submit_assistance_request
                post :create, FactoryGirl.build(form_posts[genre], :button => 'confirm')
              end

              it 'redirects to the order status page' do
                post :create, FactoryGirl.build(form_posts[genre], :button => 'confirm')
                assistance_request_id = AssistanceRequest.first.id
                order = Order.where(:assistance_request_id => assistance_request_id).first
                expect(response).to redirect_to order_status_path(:uuid => order.uuid)
              end
            end
          end

          context 'when genre is patent' do
            it 'stores the assistance request' do
              expect {
                post :create, FactoryGirl.build(form_posts['patent'], :button => 'confirm')
              }.to change(assistance_request_classes['patent'], :count).by 1
            end

            it 'creates an order for the assistance request' do
              expect {
                post :create, FactoryGirl.build(form_posts['patent'], :button => 'confirm')
              }.to change(Order, :count).by 1
            end

            it 'does not create an issue in the library support redmine' do
              allow(LibrarySupport).to receive(:delay).and_return LibrarySupport
              expect(LibrarySupport).to_not receive :submit_assistance_request
              post :create, FactoryGirl.build(form_posts['patent'], :button => 'confirm')
            end

            it 'sends a mail to patlib' do
            end
          end

          context 'when genre is book' do
            context 'when user suggests book acquisition' do
              it 'sends a book suggestion email' do
                allow(SendIt).to receive(:delay).and_return SendIt
                expect(SendIt).to receive :send_book_suggestion
                post :create, FactoryGirl.build(:book_suggestion_assistance_request_form_post, :button => 'confirm' )
              end
            end
          end
        end

        context 'when button parameter is create' do
          it 'assigns the assistance request object' do
            post :create, FactoryGirl.build(:journal_article_assistance_request_form_post, :button => 'create')
            expect(assigns[:assistance_request]).to_not be_nil
          end

          context 'when resolving' do
            context 'with 0 results' do
              it 'renders the "create" template' do
                post :create, FactoryGirl.build(:journal_article_assistance_request_form_post, :button => 'create')
                expect(response).to render_template :create
              end
            end
            context 'with 1 or more results' do
              it 'redirects to the resolver' do
                assistance_request_form = FactoryGirl.build(:journal_article_from_index_assistance_request_form_post, :button => 'create')
                post :create, assistance_request_form
                openurl_str = JournalArticleAssistanceRequest.new(assistance_request_form[:assistance_request]).openurl.kev
                openurl_str.slice!(/&ctx_tim=[^&]*/)
                redirect_url = "#{resolve_path}?#{openurl_str}&#{assistance_request_form.delete_if{|k,v| [:button, :genre].include?(k)}.to_query}&assistance_genre=journal_article"
                expect(response).to redirect_to redirect_url
              end
            end
          end

          context 'when it already has been resolved' do
            it 'renders the "create" template' do
              post :create, FactoryGirl.build(:journal_article_from_index_assistance_request_form_post, :button => 'create', :resolved => true)
              expect(response).to render_template :create
            end
          end

        end

        context 'with missing or invalid button parameter' do
          it 'renders the "create" template' do
            post :create, FactoryGirl.build(:journal_article_assistance_request_form_post)
            expect(response).to render_template :create
          end
        end

      end

      context 'when missing required parameters' do
      end

      context 'when missing genre parameter' do
        it 'returns an HTTP 400' do
          post :create, :assistance_request => FactoryGirl.attributes_for(:journal_article_assistance_request)
          expect( response.response_code ).to eq 400
        end
      end
    end

    context 'when user cannot request assistance' do
      it 'returns an HTTP 404' do
        post :create, :assistance_request => FactoryGirl.attributes_for(:journal_article_assistance_request)
        expect( response.response_code ).to eq 404
      end
    end
  end

end

def form_posts
  {
    'journal article'    => :journal_article_assistance_request_form_post,
    'conference article' => :conference_article_assistance_request_form_post,
    'book'               => :book_assistance_request_form_post,
    'thesis'             => :thesis_assistance_request_form_post,
    'report'             => :report_assistance_request_form_post,
    'standard'           => :standard_assistance_request_form_post,
    'patent'             => :patent_assistance_request_form_post,
    'other'              => :other_assistance_request_form_post
  }
end

def assistance_request_classes
  {
    'journal article'    => JournalArticleAssistanceRequest,
    'conference article' => ConferenceArticleAssistanceRequest,
    'book'               => BookAssistanceRequest,
    'thesis'             => ThesisAssistanceRequest,
    'report'             => ReportAssistanceRequest,
    'standard'           => StandardAssistanceRequest,
    'patent'             => PatentAssistanceRequest,
    'other'              => OtherAssistanceRequest
  }
end
