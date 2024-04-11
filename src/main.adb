with Ada.Text_IO, GNAT.Semaphores; use Ada.Text_IO, GNAT.Semaphores;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Containers.Indefinite_Doubly_Linked_Lists; use Ada.Containers;

procedure Main is
   package Integer_Lists is new Indefinite_Doubly_Linked_Lists (Integer);
   use Integer_Lists;

   procedure Storage (Capacity: in Integer) is
   Items_Storage: List;
   Space_Available: Counting_Semaphore (Capacity, Default_Ceiling);
   Items_Avalable: Counting_Semaphore (0, Default_Ceiling);

   task Producer;
   task Consumer;

   task body Producer is
   begin
      for I in 0 .. Capacity loop
         Space_Available.Seize;
         Items_Storage.Append(I);
         Put_Line("Producer added item:" & I'Img);
         Items_Avalable.Release;

         delay 1.5;
      end loop;
   end Producer;

   task body Consumer is
   begin
      for I in 0 .. Capacity loop
         Items_Avalable.Seize;

         declare
            Item: Integer := First_Element (Items_Storage);
         begin
            Put_Line("Consumer deleted item:" & Item'Img);
         end;

         Items_Storage.Delete_First;

         Space_Available.Release;
         delay 2.5;
      end loop;
   end Consumer;

   begin
      null;
   end Storage;

begin
   Storage(10);
end Main;

