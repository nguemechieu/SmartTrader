package SmartTraderModule;

import javafx.application.Application;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.input.MouseEvent;
import javafx.scene.web.WebView;
import javafx.stage.Stage;

public class Main extends Application {




    @FXML private WebView webView;
    @Override
    public void start(Stage primaryStage) throws Exception{
        Parent root = FXMLLoader.load(getClass().getResource("SmartTraderModule.fxml"));
        primaryStage.setTitle(getClass().getName());
        primaryStage.setScene(new Scene(root));
        primaryStage.show();
    }


    public static void main(String[] args) {
        launch(args);
    }

    public void isMenuBarId(MouseEvent event) {
    }

    public void isWebview(MouseEvent event) {
    }
}
