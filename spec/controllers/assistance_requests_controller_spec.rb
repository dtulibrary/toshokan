require 'spec_helper'

describe AssistanceRequestsController do
  before do
    @user = login FactoryGirl.create(:dtu_employee)
    @ability = FactoryGirl.build :ability
    controller.stub(:current_ability).and_return @ability
  end

  describe '#index' do 
    before do
      other_user = FactoryGirl.create :dtu_employee, :identifier => '4321'
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
          assigns[:assistance_requests].should == [@request1, @request2]
        end

        it 'renders the "index" template' do
          get :index
          should render_template :index
        end
      end

      context 'when user can view own requests' do
        before do
          @ability.can :view, :own_assistance_requests
        end

        it 'assigns all requests for the current user' do
          get :index
          assigns[:assistance_requests].should == @request1
        end
        
        it 'renders the "index" template' do
          get :index
          should render_template :index
        end
      end

      context 'when user cannot view requests' do
        it 'returns an HTTP 404' do
          get :index
          response.response_code.should == 404
        end
      end

    end

    context 'when user cannot request assistance' do
      it 'returns an HTTP 404' do
        get :index
        response.response_code.should == 404
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
              assigns[:assistance_request].class.name.underscore.should == "#{genre.gsub ' ', '_'}_assistance_request"
            end

            it 'renders the "new" template' do
              get :new, :genre => genre.gsub(' ', '_').to_sym
              should render_template :new
            end
          end
        end
      end
    end

    context 'when user cannot request assistance' do
      it 'renders the "need_to_login" template' do
        get :new
        should render_template :need_to_login
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

              it 'sends a mail to delivery support' do
                SendIt.delay.should_receive :send_request_assistance_mail
                post :create, FactoryGirl.build(form_posts[genre], :button => 'confirm')
              end

              it 'redirects to #show' do
                post :create, FactoryGirl.build(form_posts[genre], :button => 'confirm')
                should redirect_to assistance_request_path(assistance_request_classes[genre].send :first)
              end
            end
          end
        end

        context 'when button parameter is create' do
          it 'assigns the assistance request object' do
            post :create, FactoryGirl.build(:journal_article_assistance_request_form_post, :button => 'create')
            assigns[:assistance_request].should_not be_nil
          end

          it 'renders the "create" template' do
            post :create, FactoryGirl.build(:journal_article_assistance_request_form_post, :button => 'create')
            should render_template :create
          end
        end

        context 'with missing or invalid button parameter' do
          it 'renders the "create" template' do
            post :create, FactoryGirl.build(:journal_article_assistance_request_form_post)
            should render_template :create
          end
        end

      end
      
      context 'when missing required parameters' do
      end

      context 'when missing genre parameter' do
        it 'returns an HTTP 400' do
          post :create, :assistance_request => FactoryGirl.attributes_for(:journal_article_assistance_request)
          response.response_code.should == 400
        end
      end
    end

    context 'when user cannot request assistance' do
      it 'returns an HTTP 404' do
        post :create, :assistance_request => FactoryGirl.attributes_for(:journal_article_assistance_request)
        response.response_code.should == 404
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
        AssistanceRequest.should_receive(:exists?).with(@assistance_request.id.to_s)
        get :show, :id => @assistance_request.id
      end

      context 'with valid id parameter' do
        it 'finds the assistance request object' do
          AssistanceRequest.should_receive(:find).with(@assistance_request.id.to_s)
          get :show, :id => @assistance_request.id
        end

        it 'assigns the assistance request object' do
          get :show, :id => @assistance_request.id
          assigns[:assistance_request].should == @assistance_request
        end

        it 'renders the "show" template' do
          get :show, :id => @assistance_request.id
          should render_template :show
        end
      end

      context 'with missing or invalid id parameter' do
        it 'returns an HTTP 404' do
          get :show, :id => 'non-existing' 
          response.response_code.should == 404
        end
      end
    end

    context 'when user cannot request assistance' do
      it 'returns an HTTP 404' do
        get :show, :id => @assistance_request.id 
        response.response_code.should == 404
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
