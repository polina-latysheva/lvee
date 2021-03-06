require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NewsController do

  def mock_news(stubs={})
    @mock_news ||= model_stub(News, stubs)
  end

  before :all do
    @user=stub(:id => 1, :editor? => false, :admin? => false)
    @editor=stub(:id => 2, :editor? => true, :admin? => false)
    @admin=stub(:id => 2, :editor? => true, :admin? => true)
  end

  describe "responding to GET index" do

    describe "not editor" do
      it "should expose all news as @news" do
        delegate = mock()
        delegate.expects(:translated).returns([mock_news])
        News.expects(:published).returns(delegate)
        get :index
        assigns[:news].should == [mock_news]
      end

      describe "with mime type of xml" do
        it "should render all news as xml" do
          request.env["HTTP_ACCEPT"] = "application/xml"
          delegate = mock()
          news = mock("Array of News")
          delegate.expects(:translated).with().returns(news)
          News.expects(:published).returns(delegate)
          news.expects(:to_xml).returns("generated XML")
          get :index
          response.body.should == "generated XML"
        end
      end
    end

    describe "editor" do
      it "should expose all news as @news" do
        login_as @editor
        News.expects(:translated).with().returns([mock_news])
        get :index
        assigns[:news].should == [mock_news]
      end

      describe "with mime type of xml" do
        it "should render all news as xml" do
          login_as @editor
          request.env["HTTP_ACCEPT"] = "application/xml"
          news = mock("Array of News")
          News.expects(:translated).with().returns(news)
          news.expects(:to_xml).returns("generated XML")
          get :index
          response.body.should == "generated XML"
        end
      end
    end
  end

  describe "responding to GET show" do

    it "should expose the requested news as @news" do
      News.expects(:find).with("37").returns(mock_news)
      mock_news.expects(:translation).returns(mock_news)
      get :show, :id => "37"
      assigns[:news].should equal(mock_news)
    end

    describe "with mime type of xml" do

      it "should render the requested news as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        News.expects(:find).with("37").returns(mock_news)
        mock_news.expects(:translation).returns(mock_news)
        mock_news.expects(:to_xml).returns("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end

  end

  describe "responding to GET new" do
    it "shouldn't be accessible for non-logined user" do
      get :new
      response.should redirect_to(new_session_path)
    end

    it "shouldn't be accessible for normal user" do
      login_as @user
      get :new
      assert_response 403
    end

    describe "should expose a new news as @news" do
      it "populating news by parameter" do
        login_as @editor
        News.expects(:new).returns(mock_news)
        mock_news.expects(:locale=).with('be')
        mock_news.expects(:parent_id=).with("5")
        parent = model_stub(News, :title => "Title", :lead => "Lead", :body => "Body")
        mock_news.expects(:title=).with("Title")
        mock_news.expects(:lead=).with("Lead")
        mock_news.expects(:body=).with("Body")
        News.expects(:find).with('5').returns(parent)

        get :new, :locale => 'be', :parent_id => '5'
        assert_response :success
        assigns[:news].should equal(mock_news)
      end

      it "using default locale by default" do
        login_as @editor
        News.expects(:new).returns(mock_news)
        I18n.stubs(:default_locale).returns('zz')
        mock_news.expects(:locale=).with('zz')
        get :new
        assert_response :success
        assigns[:news].should equal(mock_news)
      end
    end

  end

  describe "responding to GET edit" do
    it "shouldn't be accessible for non-logined user" do
      get :edit
      response.should redirect_to(new_session_path)
    end

    it "shouldn't be accessible for normal user" do
      login_as @user
      get :edit
      assert_response 403
    end

    it "should expose the requested news as @news" do
      login_as @editor
      News.expects(:find).with("37").returns(mock_news)
      get :edit, :id => "37"
      assigns[:news].should equal(mock_news)
    end

  end

  describe "responding to POST create" do
    it "shouldn't be accessible for non-logined user" do
      post :create
      response.should redirect_to(new_session_path)
    end

    it "shouldn't be accessible for normal user" do
      login_as @user
      post :create
      assert_response 403
    end

    describe "with valid params" do

      it "should expose a newly created news as @news" do
        login_as @editor
        n = mock_news(:save => true)
        News.expects(:new).with({'these' => 'params'}).returns(n)
        n.expects(:user=).with(@editor)
        post :create, :news => {:these => 'params'}
        assigns(:news).should equal(mock_news)
      end

      it "should redirect to the created news" do
        login_as @editor
        n = mock_news(:save => true)
        News.stubs(:new).returns(n)
        n.expects(:user=).with(@editor)
        post :create, :news => {}
        response.should redirect_to(news_item_url(:id=>n))
      end

    end

    describe "with invalid params" do

      it "should expose a newly created but unsaved news as @news" do
        login_as @editor
        n = mock_news(:save => true)
        News.stubs(:new).with({'these' => 'params'}).returns(n)
        n.expects(:user=).with(@editor)
        post :create, :news => {:these => 'params'}
        assigns(:news).should equal(mock_news)
      end

      it "should re-render the 'new' template" do
        login_as @editor
        n = mock_news(:save => false)
        News.stubs(:new).returns(n)
        n.expects(:user=).with(@editor)
        post :create, :news => {}
        response.should render_template('new')
      end

    end

  end

  describe "responding to PUT update" do
    it "shouldn't be accessible for non-logined user" do
      post :update
      response.should redirect_to(new_session_path)
    end

    it "shouldn't be accessible for normal user" do
      login_as @user
      post :update
      assert_response 403
    end

    describe "with valid params" do

      it "should update the requested news" do
        login_as @editor
        News.expects(:find).with("37").returns(mock_news)
        mock_news.expects(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :news => {:these => 'params'}
      end

      it "should expose the requested news as @news" do
        login_as @editor
        News.stubs(:find).returns(mock_news(:update_attributes => true))
        put :update, :id => "1"
        assigns(:news).should equal(mock_news)
      end

      it "should redirect to the news" do
        login_as @editor
        mock = mock_news(:update_attributes => true)
        News.stubs(:find).returns(mock)
        put :update, :id => "1"
        response.should redirect_to(news_item_url(:id=>mock))
      end

    end

    describe "with invalid params" do

      it "should update the requested news" do
        login_as @editor
        News.expects(:find).with("37").returns(mock_news)
        mock_news.expects(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :news => {:these => 'params'}
      end

      it "should expose the news as @news" do
        login_as @editor
        News.stubs(:find).returns(mock_news(:update_attributes => false))
        put :update, :id => "1"
        assigns(:news).should equal(mock_news)
      end

      it "should re-render the 'edit' template" do
        login_as @editor
        News.stubs(:find).returns(mock_news(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do
    it "shouldn't be accessible for non-logined user" do
      delete :destroy
      response.should redirect_to(new_session_path)
    end

    it "shouldn't be accessible for normal user" do
      login_as @user
      delete :destroy
      assert_response 403
    end


    it "should destroy the requested news" do
      login_as @editor
      News.expects(:find).with("37").returns(mock_news)
      mock_news.expects(:destroy)
      delete :destroy, :id => "37"
    end

    it "should redirect to the news list" do
      login_as @editor
      News.stubs(:find).returns(mock_news(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(news_url)
    end
  end

  describe "responding to publish" do
    it "shouldn't be accessible for non-logined user" do
      get :publish
      response.should redirect_to(new_session_path)
    end

    it "shouldn't be accessible for normal user" do
      login_as @user
      get :publish
      assert_response 403
    end


    it "should publish the requested news" do
      login_as @editor
      News.expects(:find).with("37").returns(mock_news)
      mock_news.expects(:publish)
      get :publish, :id => "37"
    end

    it "should publish parent news if exists" do
      login_as @editor
      mock_news(:parent_id => 42);
      News.expects(:find).with("37").returns(mock_news)
      parent_news = mock
      parent_news.stubs(:id).returns(1)
      News.expects(:find).with(42).returns(parent_news)
      parent_news.expects(:publish)
      get :publish, :id => "37"
    end

    it "should redirect to the news list" do
      login_as @editor
      News.stubs(:find).returns(mock_news(:publish => true))
      delete :publish, :id => "1"
      response.should redirect_to(news_item_url(:id => mock_news.id))
    end
  end

  describe "responding to publish_now" do
    it "shouldn't be accessible for non-logined user" do
      get :publish_now
      response.should redirect_to(new_session_path)
    end

    it "shouldn't be accessible for normal user" do
      login_as @user
      get :publish_now
      assert_response 403
    end

    it "shouldn't be accessible for normal user" do
      login_as @editor
      get :publish_now
      assert_response 403
    end

    it "should publish the requested news" do
      login_as @admin
      News.expects(:find).with("37").returns(mock_news)
      mock_news.expects(:publish_now)
      get :publish_now, :id => "37"
    end

    it "should publish parent news if exists" do
      login_as @admin
      mock_news(:parent_id => 42);
      News.expects(:find).with("37").returns(mock_news)
      parent_news = mock
      parent_news.stubs(:id).returns(1)
      News.expects(:find).with(42).returns(parent_news)
      parent_news.expects(:publish_now)
      get :publish_now, :id => "37"
    end

    it "should redirect to the news list" do
      login_as @admin
      News.stubs(:find).returns(mock_news(:publish_now => true))
      get :publish_now, :id => "1"
      response.should redirect_to(news_item_url(:id => mock_news.id))
    end
  end

  describe "responding to GET rss" do
    it "should expose all news as @news" do
      delegate = mock()
      delegate.expects(:translated).returns([mock_news])
      News.expects(:published).returns(delegate)
      get :rss
      assigns[:news].should == [mock_news]
    end
  end

end
