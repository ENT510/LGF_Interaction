import React, { useState, useEffect } from "react";
import "./index.css";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { library } from "@fortawesome/fontawesome-svg-core";
import * as Icons from "@fortawesome/free-solid-svg-icons";
import { IconDefinition } from "@fortawesome/fontawesome-svg-core";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { Image } from "@mantine/core";

const getIconByName = (iconName: string): IconDefinition => {
  const name = `fa${iconName .split("-") .map(word => word.charAt(0).toUpperCase() + word.slice(1)).join("")}`;
  return Icons[name as keyof typeof Icons] as IconDefinition || Icons.faQuestion;
};

const allowedPrefixes = ["fas", "far", "fal", "fad", "fab", "fa"];

library.add(
  ...Object.values(Icons).filter(
    (icon): icon is IconDefinition => allowedPrefixes.includes((icon as IconDefinition).prefix)
  )
);

const Interaction: React.FC<{
  visible: boolean;
  dataBind: Array<{
    title: string;
    icon: string;
    description: string;
    index: number;
    image?: string;
    buttonColor?: string; 
  }> ;
}> = ({ visible, dataBind }) => {
  const [activeIndex, setActiveIndex] = useState(1);

  useEffect(() => {
    if (!visible) {
      setActiveIndex(1); 
    }
  }, [visible]);

  useNuiEvent<any>("updateIndex", (data) => {
    if (!visible) return;

    if (data.direction === "up") {
      setActiveIndex((prevIndex) =>
        prevIndex > 1 ? prevIndex - 1 : dataBind.length
      );
    } else if (data.direction === "down") {
      setActiveIndex((prevIndex) =>
        prevIndex < dataBind.length ? prevIndex + 1 : 1
      );
    }
  });

  return (
    <div className={`menu ${visible ? "slide-in" : "slide-out"}`}>
      {dataBind.length === 0 ? (
        <div className="menu-item">
          <div className="content">
            <div className="title">No Options</div>
          </div>
        </div>
      ) : (
        dataBind.map((item, index) => {
          const isActive = index + 1 === activeIndex; 
          return (
            <div
              key={item.index}
              className={`menu-item ${isActive ? "active" : ""}`}
              style={{
                backgroundColor: isActive ? item.buttonColor : 'transparent',
                boxShadow: isActive ? `0 0 5px ${item.buttonColor}` : 'none', 
                transition: 'background-color 0.2s ease, box-shadow 0.2s ease', 
              }}
            >
              <div className="icon">
                <FontAwesomeIcon icon={getIconByName(item.icon)} />
              </div>
              <div className="content">
                <div className="title">{item.title}</div>
                <div className="description">{item.description}</div>
                {item.image && ( 
                  <Image
                    src={item.image}
                    alt={item.title}
                    width={150}
                    height={150}
                    style={{ marginTop: '8px' }}
                  />
                )}
              </div>
            </div>
          );
        })
      )}
    </div>
  );
};

export default Interaction;
