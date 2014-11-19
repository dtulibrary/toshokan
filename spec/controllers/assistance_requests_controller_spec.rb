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

      context 'with valid genre parameter' do
        ['journal article', 'conference article', 'book'].each do |genre|
          context "when genre is #{genre}" do
            it "assigns a new #{genre} article assistance request object" do
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
          ['journal article', 'conference article', 'book'].each do |genre|
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

          if show_feature?(:cff_resolver)
            context 'when resolving' do
              context 'to 0 results' do
                it 'renders the "create" template' do
                  post :create, FactoryGirl.build(:journal_article_assistance_request_form_post, :button => 'create')
                  expect(response).to render_template :create
                end
              end
              context 'to 1 or more results' do
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
          else
            it 'renders the "create" template' do
              post :create, FactoryGirl.build(:journal_article_assistance_request_form_post, :button => 'create')
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



  describe '#show' do
    before do
      @assistance_request = FactoryGirl.build :journal_article_assistance_request
      @assistance_request.user = @user
      @assistance_request.save!
    end

    context 'when user can request assistance' do
      before do
        @ability.can :request, :assistance
      end

      it 'checks if an object with the supplied id exists' do
        expect(AssistanceRequest).to receive(:exists?).with(@assistance_request.id.to_s)
        get :show, :id => @assistance_request.id
      end

      context 'with valid id parameter' do
        it 'finds the assistance request object' do
          expect(AssistanceRequest).to receive(:find).with(@assistance_request.id.to_s)
          get :show, :id => @assistance_request.id
        end

        it 'assigns the assistance request object' do
          get :show, :id => @assistance_request.id
          expect(assigns[:assistance_request]).to eq @assistance_request
        end

        it 'renders the "show" template' do
          get :show, :id => @assistance_request.id
          expect(response).to render_template :show
        end
      end

      context 'with missing or invalid id parameter' do
        it 'returns an HTTP 404' do
          get :show, :id => 'non-existing'
          expect( response.response_code ).to eq 404
        end
      end
    end

    context 'when user cannot request assistance' do
      it 'returns an HTTP 404' do
        get :show, :id => @assistance_request.id
        expect( response.response_code ).to eq 404
      end
    end
  end
end

def form_posts
  {
    'journal article' => :journal_article_assistance_request_form_post,
    'conference article' => :conference_article_assistance_request_form_post,
    'book' => :book_assistance_request_form_post
  }
end

def assistance_request_classes
  {
    'journal article' => JournalArticleAssistanceRequest,
    'conference article' => ConferenceArticleAssistanceRequest,
    'book' => BookAssistanceRequest
  }
end
