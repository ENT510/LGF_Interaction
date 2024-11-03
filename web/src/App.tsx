import { useEffect, useState } from "react";
import { useNuiEvent } from "./hooks/useNuiEvent";
import { fetchNui } from "./utils/fetchNui";
import { debugData } from "./utils/debugData";
import "./components/index.css";
import Menu from "./components/Menu";
debugData([], 100);



const App: React.FC = () => {
  const [menuVisible, setMenuVisible] = useState(false);
  const [dataBind, setDataBind] = useState([]);

  useNuiEvent<any>("openInteraction", (data) => {
    setMenuVisible(data.Visible);
    setDataBind(data.DataBind);
  });

  useEffect(() => {
    const keyHandler = (e: KeyboardEvent) => {
      const activeElement = document.activeElement;
      const isInputFocused =
        activeElement instanceof HTMLElement &&
        (activeElement.tagName === "INPUT" ||
          activeElement.tagName === "TEXTAREA" ||
          activeElement.isContentEditable);

      if (menuVisible && e.code === "Escape" && !isInputFocused) {
        setMenuVisible(false);
        fetchNui("LGF_Interaction:CloseUi", { name: "openInteraction" });
      }
    };

    window.addEventListener("keydown", keyHandler);
    return () => {
      window.removeEventListener("keydown", keyHandler);
    };
  }, [menuVisible]);

  return (
    <>
      <Menu visible={menuVisible} dataBind={dataBind} />
    </>
  );
};

export default App;
