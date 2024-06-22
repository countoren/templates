import { createRoot } from "react-dom/client";
import { IntlProvider } from "react-intl";
import { Provider } from "react-redux";


//type Props = {
//  store: Store & { settings: Settings };
//};

////TODO: should be moved to settings model
//type Settings = { lang: string };

const title = document.querySelector("head title");
if (title) {
  title.textContent = `CarlsonOps ${packageJSON.version}`;
}

type Store = typeof store;
const Root = (store: Store) => {
  return (
    <Provider store={store}>
      <ConfigProvider locale={enUS}>
        <IntlProvider
          locale={store.getState().settings.lang}
          messages={dictionary?.[store.getState().settings.lang] || {}}
        >
          <Routes />
        </IntlProvider>
      </ConfigProvider>
    </Provider>
  );
};

// This is fare to ignore due to the fact that we know in compile time about the HTML root element.
// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
createRoot(document.getElementById("root")!).render(Root(store));

