require 'spec_helper'

describe CantFindController do
  describe 'index' do
    context "with ability to view can't find forms" do
      before do
        @ability = create_ability :view, :cant_find_links
        controller.stub(:current_ability).and_return @ability
      end
      
      context 'with valid genre parameter' do
        it 'assigns the genre' do
          get :index, :genre => :journal_article
          assigns[:genre].should == :journal_article
        end

        context 'when genre is journal article' do
          it 'assigns the journal article tips' do
            get :index, :genre => :journal_article
            assigns[:tips].should == ['refine_search', 'google_scholar']
          end

          it 'assigns the journal article form sections' do
            get :index, :genre => :journal_article
            assigns[:form_sections].should == ['article', 'journal', 'notes', ['email', 'physical_location', 'submit']]
          end

        end

        context 'when genre is conference article' do
          it 'assigns the conference article tips' do
            get :index, :genre => :conference_article
            assigns[:tips].should == ['refine_search']
          end

          it 'assigns the conference article form sections' do
            get :index, :genre => :conference_article
            assigns[:form_sections].should == [['article', 'proceedings'], 'conference', 'notes', ['email', 'physical_location', 'submit']]
          end
        end

        context 'when genre is book' do
          it 'assigns the book tips' do
            get :index, :genre => :book
            assigns[:tips].should == ['refine_search', 'bibliotek_dk', 'google_books']
          end

          it 'assigns the book form sections' do
            get :index, :genre => :book
            assigns[:form_sections].should == ['book', 'publisher', 'notes', ['email', 'physical_location', 'submit']]
          end
        end

        it 'renders the index template' do
          get :index, :genre => :journal_article
          should render_template :index
        end
      end

      context 'with invalid genre parameter' do
        it 'returns an HTTP 400' do
          get :index, :genre => :invalid_genre
          response.response_code.should == 400
        end
      end

    end

    context "without ability to view can't find forms" do
      it 'returns an HTTP 404' do
        get :index, :genre => :journal_article
        response.response_code.should == 404
      end
    end
  end

  describe 'assistance' do
    context 'with mandatory form fields' do
      context 'when genre is journal article' do
      end

      context 'when genre is conference article' do
      end
      
      context 'when genre is book' do
      end

      it 'renders the assistance template' do
        post :assistance, :genre => :journal_article
        should render_template :assistance
      end
    end

    context 'without mandatory form fields' do
    end
  end

end
